/datum/data/pda/utility/flashlight
	name = "Enable Flashlight"
	icon = "lightbulb-o"

	var/fon = 0 //Is the flashlight function on?

/datum/data/pda/utility/flashlight/start()
	fon = !fon
	name = fon ? "Disable Flashlight" : "Enable Flashlight"
	pda.update_shortcuts()
	var/static/pda_light = image('icons/obj/pda.dmi', "pda-light")
	pda.set_light_on(fon)

	if(fon)
		pda.add_overlay(pda_light)
	else
		pda.cut_overlay(pda_light)

/datum/data/pda/utility/honk
	name = "Honk Synthesizer"
	icon = "smile-o"
	category = "Clown"

	var/last_honk //Also no honk spamming that's bad too

/datum/data/pda/utility/honk/start()
	if(!(last_honk && world.time < last_honk + 20))
		playsound(pda.loc, 'sound/items/bikehorn.ogg', 50, 1)
		last_honk = world.time

/datum/data/pda/utility/toggle_door
	name = "Toggle Door"
	icon = "external-link-alt"
	var/remote_door_id = ""

/datum/data/pda/utility/toggle_door/start()
	for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
		if(M.id_tag == remote_door_id)
			if(M.density)
				M.open()
			else
				M.close()

/datum/data/pda/utility/scanmode/medical
	base_name = "Med Scanner"
	icon = "heart-o"

/datum/data/pda/utility/scanmode/medical/scan_mob(mob/living/M, mob/living/user)
	user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>", "<span class='notice'>You analyze [M]'s vitals.</span>")

	healthscan(user, M, 1)

/datum/data/pda/utility/scanmode/dna
	base_name = "DNA Scanner"
	icon = "link"

/datum/data/pda/utility/scanmode/dna/scan_mob(mob/living/C as mob, mob/living/user as mob)
	if(istype(C, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = C
		if(!istype(H.dna, /datum/dna))
			to_chat(user, "<span class='notice'>No fingerprints found on [H]</span>")
		else
			to_chat(user, "<span class='notice'>[H]'s Fingerprints: [md5(H.dna.uni_identity)]</span>")
	scan_blood(C, user)

/datum/data/pda/utility/scanmode/dna/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	scan_blood(A, user)

/datum/data/pda/utility/scanmode/dna/proc/scan_blood(atom/A, mob/user)
	if(!A.blood_DNA)
		to_chat(user, "<span class='notice'>No blood found on [A]</span>")
		if(A.blood_DNA)
			qdel(A.blood_DNA)
	else
		to_chat(user, "<span class='notice'>Blood found on [A]. Analysing...</span>")
		spawn(15)
			for(var/blood in A.blood_DNA)
				to_chat(user, "<span class='notice'>Blood type: [A.blood_DNA[blood]]\nDNA: [blood]</span>")

/datum/data/pda/utility/scanmode/halogen
	base_name = "Halogen Counter"
	icon = "exclamation-circle"

/datum/data/pda/utility/scanmode/halogen/scan_mob(mob/living/C as mob, mob/living/user as mob)
	C.visible_message("<span class='warning'>[user] has analyzed [C]'s radiation levels!</span>")

	user.show_message("<span class='notice'>Analyzing Results for [C]:</span>")
	if(C.radiation)
		user.show_message("<span class='notice'>Radiation Level: [C.radiation > 0 ? "</span><span class='danger'>[C.radiation]" : "0"]</span>")
	else
		user.show_message("<span class='notice'>No radiation detected.</span>")

/datum/data/pda/utility/scanmode/reagent
	base_name = "Reagent Scanner"
	icon = "flask"

/datum/data/pda/utility/scanmode/reagent/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	if(!isnull(A.reagents))
		if(A.reagents.reagent_list.len > 0)
			var/reagents_length = A.reagents.reagent_list.len
			to_chat(user, "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>")
			for(var/datum/reagent/R in A.reagents.reagent_list)
				if(R.id != "blood")
					to_chat(user, "<span class='notice'>\t [R]</span>")
				else
					var/blood_type = R.data["blood_type"]
					var/blood_species = R.data["blood_species"]
					to_chat(user, "<span class='notice'>\t [R] [blood_type] [blood_species]</span>")
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in [A].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents found in [A].</span>")

/datum/data/pda/utility/scanmode/gas
	base_name = "Gas Scanner"
	icon = "tachometer-alt"

/datum/data/pda/utility/scanmode/gas/scan_atom(atom/A, mob/user)
	atmos_scan(user=user, target=A, silent=FALSE, print=TRUE)
