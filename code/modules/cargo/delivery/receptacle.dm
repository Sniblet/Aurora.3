var/global/list/all_cargo_receptacles = list()

/obj/structure/cargo_receptacle
	name = "cargo delivery point"
	desc = "An Orion Express automated cargo acceptance device. It's linked to a vast underground network of conveyors and de-sterilizers, transporting it to its final destination. These are generally used by researchers who find themselves bunkered alone on an exoplanet."
	desc_info = "This is a delivery point for Orion Express cargo packages. To finish the delivery, have a cargo package in your hand and click on the delivery point."
	icon = 'icons/obj/orion_delivery.dmi'
	icon_state = "delivery_point"

	var/delivery_id = ""
	var/datum/weakref/delivery_sector

	var/spawns_packages = TRUE

/obj/structure/cargo_receptacle/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/cargo_receptacle/LateInitialize()
	delivery_id = "#[rand(1, 9)][rand(1, 9)][rand(1, 9)]"
	name += " ([delivery_id])"

	if(SSatlas.current_map.use_overmap)
		var/turf/current_turf = get_turf(loc)
		var/obj/effect/overmap/visitable/my_sector = GLOB.map_sectors["[current_turf.z]"]
		if(my_sector)
			delivery_sector = WEAKREF(my_sector)
		else
			delivery_sector = null
	else
		delivery_sector = null

	all_cargo_receptacles += src

	if(spawns_packages)
		var/list/warehouse_turfs = list()
		for(var/area_path in typesof(SSatlas.current_map.warehouse_basearea))
			var/area/warehouse = locate(area_path)
			if(warehouse)
				for(var/turf/simulated/floor/T in warehouse)
					if(!turf_contains_dense_objects(T))
						warehouse_turfs += T

		var/package_amount = rand(2, 4)
		for(var/i = 1 to package_amount)
			var/turf/random_turf = pick_n_take(warehouse_turfs)
			if(random_turf)
				new /obj/item/cargo_package(random_turf, src)

/obj/structure/cargo_receptacle/Destroy()
	all_cargo_receptacles -= src
	return ..()

/obj/structure/cargo_receptacle/attackby(obj/item/item, mob/user)
	if(istype(item, /obj/item/cargo_package))
		var/obj/item/cargo_package/package = item
		if(!package.associated_delivery_point)
			to_chat(user, SPAN_WARNING("Something's wrong with the cargo package, submit a bug report. ERRCODE: 0"))
			return

		if(package.associated_delivery_point.resolve() != src)
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			visible_message(SPAN_WARNING("\The [src] buzzes harshly, \"Invalid package! Check the delivery ID!\""))
			return

		user.visible_message("<b>[user]</b> starts heaving \the [item] into \the [src]...", SPAN_NOTICE("You start heaving \the [item] into \the [src]..."))
		if(do_after(user, 1 SECONDS, src, DO_UNIQUE))
			user.drop_from_inventory(item, src)
			pay_account(user, item)
			qdel(item)
		return
	return ..()

/obj/structure/cargo_receptacle/proc/pay_account(var/mob/living/carbon/human/courier, var/obj/item/cargo_package/package)
	if(package.pays_horizon_account)
		var/datum/money_account/supply_account = SScargo.supply_account
		if(supply_account && !supply_account.suspended)
			supply_account.money += package.pay_amount

			//create a transaction log entry
			var/datum/transaction/transaction = new()
			transaction.target_name = "Successful Delivery"
			transaction.purpose = "Payment for completed Courier Duty"
			transaction.amount = "[package.pay_amount]"
			transaction.date = worlddate2text()
			transaction.time = worldtime2text()
			transaction.source_terminal = capitalize_first_letters(name)
			SSeconomy.add_transaction_log(supply_account, transaction)

	var/found_user_account = FALSE
	var/obj/item/card/id_card = courier.GetIdCard()
	if(id_card?.associated_account_number)
		var/datum/money_account/courier_account = SSeconomy.get_account(id_card.associated_account_number)
		if(courier_account && !courier_account.suspended)
			var/tip_amount = package.pay_amount * 0.02
			found_user_account = TRUE

			courier_account.money += tip_amount

			//create a transaction log entry
			var/datum/transaction/transaction = new()
			transaction.target_name = "Successful Delivery"
			transaction.purpose = "2% Tip for completed Courier Duty"
			transaction.amount = "[tip_amount]"
			transaction.date = worlddate2text()
			transaction.time = worldtime2text()
			transaction.source_terminal = capitalize_first_letters(name)
			SSeconomy.add_transaction_log(courier_account, transaction)

	// if a third party ambushed and stole the package, we want to let them collect the tip wirelessly
	if(!found_user_account)
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		visible_message("\The [src] buzzes harshly, \"[SPAN_WARNING("Delivery complete! User account details not found... printing cash tip...")]\"")
		playsound(loc, /singleton/sound_category/print_sound, 50, TRUE)
		var/obj/item/spacecash/bundle/cash_tip = new /obj/item/spacecash/bundle(loc)
		cash_tip.worth = package.pay_amount * 0.02
		cash_tip.update_icon()
	else
		visible_message("\The [src] pings, \"[SPAN_NOTICE("Delivery complete! Cash deposited into supply account, tip wirelessly transmitted into courier account.")]\"")
		playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)

/obj/structure/cargo_receptacle/horizon
	spawns_packages = FALSE
