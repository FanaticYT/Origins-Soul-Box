#using scripts\shared\clientfield_shared;

#using scripts\codescripts\struct;

#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\fanatic\origins_soul_box\origins_soul_box.gsh;

#precache("client_fx", FX_ORI_SOUL_BOX_INSIDE);
#precache("client_fx", FX_ORI_SOUL_BOX_ZOMBIE_SOUL);
#precache("client_fx", FX_ORI_SOUL_BOX_ZOMBIE_SOUL_IMPACT);
#precache("client_fx", FX_ORI_SOUL_BOX_DISAPPEAR_DEBRIS);

REGISTER_SYSTEM( "origins_soul_box", &__init__, undefined )

#namespace origins_soul_box;

function __init__()
{
	clientfield::register("actor", "origins_soul_box_fx", VERSION_SHIP, 1, "int", &soul_box_fx, 0, 0);
	clientfield::register("scriptmover", "inside_origins_box_fx", VERSION_SHIP, 1, "int", &inside_box_fx, 0, 0);
}

function soul_box_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	box_array = struct::get_array( STRUCT_ORI_SOUL_BOX, "targetname" );
	soul_box = ArrayGetClosest(self.origin, box_array);

	fx_ent = Spawn(localclientnum, self GetTagOrigin("J_SpineUpper"), "script_model");
	fx_ent SetModel("tag_origin");

	fx_ent PlaySound(localclientnum, SFX_ORI_SOUL_FLUSH);
	fx_ent PlayLoopSound(SFX_ORI_SOUL_FULL_LOOP);

	soul_position_end = soul_box.origin + (0,0,25);
	soul_distance = Distance( fx_ent.origin, soul_position_end );
	soul_speed = soul_distance / ORI_SOUL_BOX_SOUL_SPEED;

	PlayFXOnTag(localclientnum, FX_ORI_SOUL_BOX_ZOMBIE_SOUL, fx_ent, "tag_origin");

	fx_ent MoveTo(soul_box.origin + (0,0,25), soul_speed);
	fx_ent waittill("movedone");

	PlaySound(localclientnum, SFX_ORI_SOUL_IMPACT, fx_ent.origin);
	PlayFXOnTag(localclientnum, FX_ORI_SOUL_BOX_ZOMBIE_SOUL_IMPACT, fx_ent, "tag_origin");

	wait(0.5);
	fx_ent Delete();
}

function inside_box_fx(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump)
{
	self util::waittill_dobj(localclientnum);
	if(newval == 1)
	{
		if(!isdefined(self.fx_glow))
		{
			self.fx_glow = PlayFXOnTag(localclientnum, FX_ORI_SOUL_BOX_INSIDE, self, "tag_origin");
		}
		if(!isdefined(self.sndent))
		{
			self.sndent = Spawn(0, self.origin, "script_origin");
			self.sndent PlayLoopSound(SFX_ORI_SOUL_BOX_FIRE_LOOP, 1);
		}
	}
	else
	{
		if(isdefined(self.fx_glow))
		{
			StopFX(localclientnum, self.fx_glow);
			self.fx_glow = undefined;
		}
		if(isdefined(self.sndent))
		{
			self.sndent Delete();
			self.sndent = undefined;
		}
	}
}
