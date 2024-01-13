

//////////// CONFIGURATION //////////////////////////////////////////////////////////////

#define ORI_SOUL_BOX_SOULS_NEEDED 				15  // Souls needed per Soul Box.

#define ORI_ENABLE_REWARD_BOX					true // set to false if you are making a custom script, the wait flag to use once all are filled is: 
//																														level flag::wait_till( "ori_soul_boxes_filled" );

//												If you do not want weapon rewards, make the array empty like so: array()
#define ORI_SOUL_BOX_WEAPON_REWARDS				array("ar_standard","lmg_cqb","ray_gun") // Weapon Names as defined in APE

#define ORI_SOUL_BOX_PERK_REWARD_RANDOM			true // Do you want a Random Perk Reward?

/////////////////////////////////////////////////////////////////////////////////////////


// Targetnames
#define STRUCT_ORI_SOUL_BOX 					"ori_soul_box_struct"
#define STRUCT_ORI_REWARD_BOX					"ori_reward_box_struct"

// Hintstrings
#define ORI_REWARD_BOX_HINT						"Hold ^3[{+activate}]^7 for reward"

// Modifiers
#define ORI_SOUL_BOX_SOUL_SPEED 				250

// Models
#define MDL_ORI_SOUL_BOX 						"ori_soul_box"
#define MDL_ORI_SOUL_BOX_ON 					"ori_soul_box_on"
#define MDL_ORI_SOUL_BOX_SOUL_ON				"ori_soul_box_soul_on"
#define MDL_ORI_REWARD_BOX						"ori_challenge_box"
#define MDL_PERK_BOTTLE_RANDOM					"perk_bottle_gold"

// Anims
#define ANIM_ORI_SOUL_BOX_OPEN 					"ori_soul_box_open_anim"
#define ANIM_ORI_SOUL_BOX_CLOSE 				"ori_soul_box_close_anim"

// FX
#define FX_ORI_SOUL_BOX_INSIDE 					"dlc5/tomb/fx_tomb_challenge_fire"
#define FX_ORI_SOUL_BOX_ZOMBIE_SOUL 			"dlc5/zmb_weapon/fx_staff_charge_souls"
#define FX_ORI_SOUL_BOX_ZOMBIE_SOUL_IMPACT 		"dlc5/zmb_weapon/fx_staff_charge"
#define FX_ORI_SOUL_BOX_DISAPPEAR_DEBRIS 		"dlc1/castle/fx_dust_landingpad"

// Sounds
#define SFX_ORI_SOUL_BOX_OPEN					"snd_ori_soul_box_open"
#define SFX_ORI_SOUL_BOX_CLOSE					"snd_ori_soul_box_close"
#define SFX_ORI_SOUL_BOX_FIRE_LOOP				"snd_ori_soul_box_fire_lp"
#define SFX_ORI_SOUL_BOX_DISAPPEAR				"snd_ori_soul_box_disappear"
#define SFX_ORI_SOUL_FLUSH						"snd_ori_soul_flush"
#define SFX_ORI_SOUL_IMPACT						"snd_ori_soul_impact"
#define SFX_ORI_SOUL_FULL						"snd_ori_charge_soul_full"
#define SFX_ORI_SOUL_FULL_LOOP					"snd_ori_charge_soul_full_loop"
