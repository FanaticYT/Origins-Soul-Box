#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;

#using scripts\shared\array_shared;

#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_perks;
#insert scripts\zm\_zm_perks.gsh;

#using scripts\zm\_zm_spawner;

#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\fanatic\origins_soul_box\origins_soul_box.gsh;

#precache("model", MDL_ORI_SOUL_BOX);
#precache("model", MDL_ORI_SOUL_BOX_ON);
#precache("model", MDL_ORI_SOUL_BOX_SOUL_ON);
#precache("model", MDL_ORI_REWARD_BOX);
#precache("model", MDL_PERK_BOTTLE_RANDOM);
#precache("triggerstring", ORI_REWARD_BOX_HINT);
#precache("xanim", ANIM_ORI_SOUL_BOX_OPEN);
#precache("xanim", ANIM_ORI_SOUL_BOX_CLOSE);
#precache("fx", FX_ORI_SOUL_BOX_DISAPPEAR_DEBRIS);
#using_animtree("ori_soul_box_anims");

REGISTER_SYSTEM( "origins_soul_box", &__init__, undefined )

#namespace origins_soul_box;

function __init__()
{
	clientfield::register("actor", "origins_soul_box_fx", VERSION_SHIP, 1, "int");
	clientfield::register("scriptmover", "inside_origins_box_fx", VERSION_SHIP, 1, "int");

	level flag::init( "ori_soul_boxes_filled" );

	level.soul_box_array = struct::get_array(STRUCT_ORI_SOUL_BOX, "targetname");
	level.soul_box = [];

	for(i=0; i<level.soul_box_array.size; i++)
	{
		level.soul_box[i] = Spawn("script_model", level.soul_box_array[i].origin);
		level.soul_box[i] SetModel(MDL_ORI_SOUL_BOX_SOUL_ON);
		level.soul_box[i].angles = level.soul_box_array[i].angles;
		level.soul_box[i].soul_box_area = GetEnt(level.soul_box_array[i].target, "targetname");
		level.soul_box[i] UseAnimTree(#animtree);
		level.soul_box[i].collision = Spawn("script_model", level.soul_box[i].origin, 1);
		level.soul_box[i].collision.angles = level.soul_box[i].angles;
		level.soul_box[i].collision SetModel("zm_collision_perks1");
		level.soul_box[i] DisconnectPaths();
		level.soul_box[i].souls_collected = 0;
		level.soul_box[i].souls_completed = 0;
		level.soul_box[i].inside_fx_on = 0;
		level.soul_box[i].anim_opened = 0;
		level.soul_box[i].anim_closed = 0;
	}

	level thread ori_reward_box();

	level thread watch_for_soul_boxes_filled();
	zm_spawner::register_zombie_death_event_callback(&collect_soul_think);
}

function collect_soul_think(attacker)
{
	if( self.archetype != "zombie" || !IsPlayer(attacker) )
	{
		return;
	}

	for(i=0; i<level.soul_box.size; i++)
	{
		if( self IsTouching(level.soul_box[i].soul_box_area) )
		{
			if( isdefined( level.soul_box[i].souls_completed ) && level.soul_box[i].souls_completed == 1 )
			{
				return;
			}

			level.soul_box[i].souls_collected++;

			if(level.soul_box[i].souls_collected >= ORI_SOUL_BOX_SOULS_NEEDED)
			{
				level.soul_box[i].souls_completed = 1;
			}

			if(level.soul_box[i].anim_opened == 0)
			{
				level.soul_box[i] AnimScripted("ori_soul_box_open", level.soul_box[i].origin, level.soul_box[i].angles, %ori_soul_box_open_anim);
				level.soul_box[i].anim_opened = 1;
			}

			self clientfield::set("origins_soul_box_fx", 1);

			temp_ent = Spawn("script_model", self GetTagOrigin("J_SpineUpper"));
			temp_ent SetModel("tag_origin");
			end_position = level.soul_box[i].origin + (0,0,25);
			soul_distance = Distance( temp_ent.origin, end_position );
			soul_speed = soul_distance / ORI_SOUL_BOX_SOUL_SPEED;
			wait soul_speed;
			temp_ent Delete();

			if(level.soul_box[i].inside_fx_on == 0)
			{
				level.soul_box[i] clientfield::set("inside_origins_box_fx", 1);
				level.soul_box[i].inside_fx_on = 1;
			}

			if( level.soul_box[i].souls_completed == 1 && level.soul_box[i].anim_closed == 0 )
			{
				level.soul_box[i].anim_closed = 1;
				level.soul_box[i] AnimScripted("ori_soul_box_close", level.soul_box[i].origin, level.soul_box[i].angles, %ori_soul_box_close_anim);
				level.soul_box[i] clientfield::set("inside_origins_box_fx", 0);
				wait_anim_close = GetAnimLength(%ori_soul_box_close_anim);
				wait wait_anim_close;
				level notify("ori_soul_box_filled");
				level.soul_box[i] thread soul_box_disappear();
			}
		}
	}
}

function soul_box_disappear()
{
	wait 1;
	self StopAnimScripted();
	v_start_angles = self.angles;
	self MoveZ(30, 1, 1);
	self.angles = v_start_angles;
	level thread play_sound( SFX_ORI_SOUL_BOX_DISAPPEAR, self.origin );
	wait(0.5);
	n_rotations = RandomIntRange(5, 7);
	for(r = 0; r<n_rotations; r++)
	{
		v_rotate_angles = v_start_angles + (RandomFloatRange(-10, 10), RandomFloatRange(-10, 10), RandomFloatRange(-10, 10));
		n_rotate_time = RandomFloatRange(0.2, 0.4);
		self RotateTo(v_rotate_angles, n_rotate_time);
		self waittill("rotatedone");
	}
	self RotateTo(v_start_angles, 0.3);
	self MoveZ(-60, 0.5, 0.5);
	self waittill("rotatedone");
	trace_start = self.origin + VectorScale((0, 0, 1), 200);
	trace_end = self.origin;
	fx_trace = BulletTrace(trace_start, trace_end, 0, self);
	PlayFX( FX_ORI_SOUL_BOX_DISAPPEAR_DEBRIS, fx_trace["position"], AnglesToForward(self.angles), AnglesToUp(self.angles) );
	self waittill("movedone");
	self ConnectPaths();
	self.collision Hide();
}

function watch_for_soul_boxes_filled()
{
	level endon("ori_soul_boxes_filled");

	boxes_filled = 0;
	boxes_needed = level.soul_box.size;

	while(boxes_filled < boxes_needed)
	{
		level waittill("ori_soul_box_filled");
		boxes_filled++;
	}

	zm_spawner::deregister_zombie_death_event_callback(&collect_soul_think);

	foreach(player in GetPlayers())
	{
		player PlaySoundToPlayer(SFX_ORI_SOUL_FULL, player);
	}
	
	level flag::set( "ori_soul_boxes_filled" );
}

function play_sound(sound, ent_origin = (0,0,0) )
{
	sound_ent = Spawn( "script_origin", ent_origin );
	sound_ent PlaySound(sound);
	sound_wait = SoundGetPlaybackTime(sound);
	converted = sound_wait * .001;
	wait converted + 1;
	sound_ent Delete();
}

function ori_reward_box()
{
	if(!ORI_ENABLE_REWARD_BOX)
	{
		return;
	}

	reward_box_struct = struct::get(STRUCT_ORI_REWARD_BOX, "targetname");
	level.ori_reward_box = Spawn("script_model", reward_box_struct.origin);
	level.ori_reward_box SetModel(MDL_ORI_REWARD_BOX);
	level.ori_reward_box.angles = reward_box_struct.angles;
	level.ori_reward_box UseAnimTree(#animtree);
	level.ori_reward_box.collision = Spawn("script_model", level.ori_reward_box.origin, 1);
	level.ori_reward_box.collision.angles = level.ori_reward_box.angles;
	level.ori_reward_box.collision SetModel("zm_collision_perks1");
	level.ori_reward_box DisconnectPaths();
	level.ori_reward_box.trigger = spawn_trigger_use(level.ori_reward_box.origin, ORI_REWARD_BOX_HINT, 80, 100, true);
	level.ori_reward_box.trigger SetInvisibleToAll();

	level flag::wait_till( "ori_soul_boxes_filled" );

	level.ori_reward_box thread rewards_think();
}

function rewards_think()
{
	weapon_rewards = ORI_SOUL_BOX_WEAPON_REWARDS;

	while(1)
	{
		foreach(player in GetPlayers())
		{
			if( !isdefined(player.ori_reward_taken) || !player.ori_reward_taken )
			{
				self.trigger SetVisibleToPlayer(player);
			}
		}

		self.trigger waittill("trigger", player);
		self.trigger SetInvisibleToAll();

		if( !ORI_SOUL_BOX_PERK_REWARD_RANDOM && weapon_rewards.size < 1 )
		{
			IPrintLnBold("^1ERROR:^7 There has to be at least 1 valid reward.");
			continue;
		}

		reward_is_weapon = false;
		reward_is_perk = false;

		choices = array("weapon", "perk");
		choice = array::random(choices);

		switch(choice) {
			case "weapon":
				if( weapon_rewards.size < 1 )
				{
					reward_is_perk = true;
				}
				else
				{
					reward_is_weapon = true;
				}
				break;
			case "perk":
				if( ORI_SOUL_BOX_PERK_REWARD_RANDOM )
				{
					reward_is_perk = true;
				}
				else
				{
					reward_is_weapon = true;
				}
				break;
		}

		self AnimScripted("ori_reward_box_open", self.origin, self.angles, %ori_soul_box_open_anim);
		level.ori_reward_box clientfield::set("inside_origins_box_fx", 1);
		wait 1;

		if( reward_is_weapon )
		{
			s_weapon = array::random(weapon_rewards);
			w_weapon = GetWeapon(s_weapon);
			w_model = GetWeaponWorldModel( w_weapon );
			reward_model = util::spawn_model(w_model, self.origin + (0,0,-11), self.angles);
			thread reward_rise(reward_model, 50, 2, 2, 10);
			self thread wait_for_player_accept(player, w_weapon, 2, &reward_player_with_weapon);
		}
		else if( reward_is_perk )
		{
			reward_model = util::spawn_model(MDL_PERK_BOTTLE_RANDOM, self.origin, self.angles);
			thread reward_rise(reward_model, 50, 2, 2, 10);
			self thread wait_for_player_accept(player, undefined, 2, &reward_player_with_perk);
		}

		level waittill("reset_ori_challenge_reward");

		if( isdefined(reward_model) )
		{
			reward_model Delete();
		}

		self.trigger SetInvisibleToAll();

		self AnimScripted("ori_reward_box_close", self.origin, self.angles, %ori_soul_box_close_anim);
		level.ori_reward_box clientfield::set("inside_origins_box_fx", 0);
		wait_anim_close = GetAnimLength(%ori_soul_box_close_anim);
		wait wait_anim_close + 2;
	}
}

function wait_for_player_accept(player, reward, n_delay, func)
{
	level endon("reset_ori_challenge_reward");

	if(isdefined(n_delay))
	{
		wait n_delay;
	}

	self.trigger SetVisibleToPlayer(player);
	self.trigger waittill("trigger", player);

	player.ori_reward_taken = true;

	player thread [[ func ]](reward);

	level notify("reset_ori_challenge_reward");
}

function reward_player_with_weapon(weapon)
{
	self zm_weapons::weapon_give( weapon, false, false, true, true );
}

function reward_player_with_perk(perk)
{
	self zm_perks::give_random_perk();
}

function reward_sink(n_delay, n_z, n_time)
{
	level endon("reset_ori_challenge_reward");

	if(isdefined(n_delay))
	{
		wait(n_delay);
		if(isdefined(self))
		{
			self MoveZ(n_z * -1, n_time);
			wait n_time;
			level notify("reset_ori_challenge_reward");
		}
	}
}
function reward_rise(m_reward, n_z, n_rise_time, n_delay, n_timeout)
{
	m_reward MoveZ(n_z, n_rise_time);
	wait(n_rise_time);
	if(n_timeout > 0)
	{
		m_reward thread reward_sink(n_delay, n_z, n_timeout + 1);
	}
}

function spawn_trigger_use( origin, hint_string = undefined, radius = 80, height = 100, require_lookat = false, spawn_flags = 0 )
{
	trig = Spawn("trigger_radius_use", origin, spawn_flags, radius, height);
	trig TriggerIgnoreTeam();
	trig SetVisibleToAll();
	trig SetTeamForTrigger("none");
	if(require_lookat)
	{
		trig UseTriggerRequireLookAt();
	}
	trig SetCursorHint("HINT_NOICON");

	if( isdefined( hint_string ) )
	{
		trig SetHintString( hint_string );
	}

	return trig;
}
