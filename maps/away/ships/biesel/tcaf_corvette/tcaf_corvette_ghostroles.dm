/datum/ghostspawner/human/tcaf_crewman
	name = "Republican Fleet Legionary"
	short_name = "tcaf_crewman"
	desc = "Crew a scout vessel of the Tau Ceti Republican Fleet. Follow your captain's orders, clear the sector of any pirate activity, and uphold the interests of the Republic of Biesel."
	tags = list("External")
	mob_name_prefix = "Lgn. "

	spawnpoints = list("tcaf_crewman")
	max_count = 3

	outfit = /datum/outfit/admin/tcaf_crewman
	possible_species = list(SPECIES_HUMAN, SPECIES_HUMAN_OFFWORLD, SPECIES_TAJARA, SPECIES_TAJARA_MSAI, SPECIES_TAJARA_ZHAN, SPECIES_SKRELL, SPECIES_SKRELL_AXIORI, SPECIES_UNATHI, SPECIES_VAURCA_WARRIOR, SPECIES_VAURCA_WORKER, SPECIES_IPC, SPECIES_IPC_G1, SPECIES_IPC_G2, SPECIES_IPC_XION, SPECIES_IPC_ZENGHU, SPECIES_IPC_BISHOP, SPECIES_IPC_SHELL, SPECIES_DIONA, SPECIES_DIONA_COEUS)
	allow_appearance_change = APPEARANCE_PLASTICSURGERY

	assigned_role = "Republican Fleet Legionary"
	special_role = "Republican Fleet Legionary"
	respawn_flag = null

/datum/outfit/admin/tcaf_crewman
	name = "TCAF Crewman"
	uniform = /obj/item/clothing/under/legion/tcaf
	gloves = /obj/item/clothing/gloves/tcaf
	shoes = /obj/item/clothing/shoes/jackboots
	back = /obj/item/storage/backpack/tcaf
	id = /obj/item/card/id
	accessory = /obj/item/clothing/accessory/holster/hip
	l_ear = /obj/item/device/radio/headset/ship
	backpack_contents = list(/obj/item/storage/box/survival = 1, /obj/item/melee/energy/sword/knife = 1)
	species_shoes = list(
		SPECIES_UNATHI = /obj/item/clothing/shoes/jackboots/toeless,
		SPECIES_TAJARA = /obj/item/clothing/shoes/jackboots/toeless,
		SPECIES_TAJARA_MSAI = /obj/item/clothing/shoes/jackboots/toeless,
		SPECIES_TAJARA_ZHAN = /obj/item/clothing/shoes/jackboots/toeless,
		SPECIES_VAURCA_WORKER = /obj/item/clothing/shoes/vaurca,
		SPECIES_VAURCA_WARRIOR =/obj/item/clothing/shoes/vaurca
	)

/datum/outfit/admin/tcaf_crewman/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(isvaurca(H))
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/vaurca/filter(H), slot_wear_mask)
		var/obj/item/organ/internal/vaurca/preserve/preserve = H.internal_organs_by_name[BP_PHORON_RESERVE]
		H.internal = preserve
		H.internals.icon_state = "internal1"
		H.equip_or_collect(new /obj/item/reagent_containers/food/snacks/koisbar, slot_in_backpack)
		var/list/fullname = splittext(H.real_name, " ")
		var/surname = fullname[3] //prefix bumps it up
		switch(surname)
			if("K'lax")
				var/obj/item/organ/A = new /obj/item/organ/internal/augment/language/klax(H)
				var/obj/item/organ/external/affected = H.get_organ(A.parent_organ)
				A.replaced(H, affected)
			if("C'thur")
				var/obj/item/organ/A = new /obj/item/organ/internal/augment/language/cthur(H)
				var/obj/item/organ/external/affected = H.get_organ(A.parent_organ)
				A.replaced(H, affected)
		H.update_body()
	if(isoffworlder(H))
		H.equip_or_collect(new /obj/item/storage/pill_bottle/rmt, slot_in_backpack)

/datum/outfit/admin/tcaf_crewman/get_id_access()
	return list(ACCESS_TCAF_SHIPS, ACCESS_EXTERNAL_AIRLOCKS)

/datum/ghostspawner/human/tcaf_crewman/nco
	name = "Republican Fleet Prefect"
	short_name = "tcaf_nco"
	max_count = 1
	outfit = /datum/outfit/admin/tcaf_crewman/nco
	mob_name_prefix = "Pfct. "
	desc = "Serve as the second-in-command of the Republican Fleet patrol vessel. Aid your commanding officer in their duties, clear the sector of any pirate activity, and uphold the interests of the Republic of Biesel."
	assigned_role = "Republican Fleet Prefect"
	special_role = "Republican Fleet Prefect"

/datum/outfit/admin/tcaf_crewman/nco
	accessory = /obj/item/clothing/accessory/legion
	backpack_contents = list(/obj/item/storage/box/survival = 1, /obj/item/melee/energy/sword/knife = 1, /obj/item/clothing/accessory/tcaf_prefect_pauldron = 1)

/datum/ghostspawner/human/tcaf_crewman/officer
	name = "Republican Fleet Officer"
	short_name = "tcaf_officer"
	max_count = 1
	spawnpoints = list("tcaf_officer")
	outfit = /datum/outfit/admin/tcaf_crewman/officer
	mob_name_prefix = "Dcn. "
	desc = "Command a patrol vessel of the Tau Ceti Republican Fleet. Sweep the sector for signs of piracy, uphold the interests of the Republic of Biesel, and try to keep your crew in one piece."
	assigned_role = "Republican Fleet Decurion"
	special_role = "Republican Fleet Decurion"

/datum/outfit/admin/tcaf_crewman/officer
	accessory = /obj/item/clothing/accessory/legion
