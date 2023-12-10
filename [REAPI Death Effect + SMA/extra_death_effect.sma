#pragma semicolon 1
#include <amxmodx>
#include <fakemeta>
#include <reapi>
#pragma compress 1

new gl_iMaxEntitie;
new gl_iModelIndex;
new gl_iSkins[MAX_PLAYERS+1];
new Float:gl_timesl[MAX_PLAYERS+1];
public plugin_precache()
{
	register_plugin("[REAPI] Death Effect", "1.0", "BRUN0");

	gl_iMaxEntitie = global_get(glb_maxEntities);
	gl_iModelIndex = precache_model("models/deffect.mdl");
}

public plugin_init() {
	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed_Post", .post = true);
}

@CBasePlayer_Killed_Post(const victim, const killer, const GibsType) {
	if(!is_user_connected(victim)) {
		return HC_CONTINUE;
	}
	@Create_effect(victim, killer);
	return HC_CONTINUE;
}

@Create_effect(const victim, const killer)
{
	if(gl_iMaxEntitie - engfunc(EngFunc_NumberOfEntities) <= 100) {
		return;
	}
	new Entity = rg_create_entity("info_null");
	if(is_nullent(Entity)) {
		return;
	}

	gl_iSkins[victim] = 0;

	new Float:xVictimOrigin[3]; 
	get_entvar(victim, var_origin, xVictimOrigin);
	xVictimOrigin[2] += 28.0;
	set_entvar(Entity, var_origin, xVictimOrigin);

	set_entvar(Entity, var_enemy, victim);
	set_entvar(Entity, var_owner, killer);

	set_entvar(Entity, var_effects, 
	get_entvar(Entity, var_effects) | EF_OWNER_VISIBILITY);

	set_entvar(Entity, var_classname, "ent_death_effect");
	set_entvar(Entity, var_modelindex, gl_iModelIndex);
	set_entvar(Entity, var_skin, gl_iSkins[victim]);
	set_entvar(Entity, var_rendermode, kRenderTransAdd);
	set_entvar(Entity, var_renderamt, 255.0);
	set_entvar(Entity, var_nextthink, get_gametime() + 0.7);
	SetThink(Entity, "@Effect_Think");
}

@Effect_Think(const Entity)
{
	if(is_nullent(Entity))
	{
		SetThink(Entity, NULL_STRING);
		return;
	}

	static Float:xtime; xtime = get_gametime();
	static enemy; enemy = get_entvar(Entity, var_enemy);
	static owner; owner = get_entvar(Entity, var_owner);

	if (gl_iSkins[enemy] >= 30)
	{
		SetThink(Entity, NULL_STRING);
		set_entvar(Entity, var_flags, FL_KILLME);
		gl_timesl[enemy] = 0.0;
	}

	static Float:xAngles[3];
	get_entvar(owner, var_v_angle, xAngles);

	xAngles[0] = 90.0;
	xAngles[1] -= 360.0;

	set_entvar(Entity, var_angles, xAngles);

	if (gl_timesl[enemy] <= xtime)
	{
		gl_timesl[enemy] = xtime + 0.04;
		gl_iSkins[enemy]++;
		set_entvar(Entity, var_skin, gl_iSkins[enemy]);
	}

	set_entvar(Entity, var_nextthink, xtime);
}