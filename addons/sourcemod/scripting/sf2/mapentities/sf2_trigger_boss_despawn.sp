// sf2_trigger_boss_despawn

// A trigger that when touched by a boss will despawn the boss from the map.

static CEntityFactory g_EntityFactory;

/**
 *	Interface that exposes public methods for interacting with the entity.
 */
methodmap SF2TriggerBossDespawnEntity < SF2TriggerMapEntity
{
	public SF2TriggerBossDespawnEntity(int entIndex) { return view_as<SF2TriggerBossDespawnEntity>(SF2TriggerMapEntity(entIndex)); }

	public bool IsValid()
	{
		if (!CBaseEntity(this.index).IsValid())
		{
			return false;
		}

		return CEntityFactory.GetFactoryOfEntity(this.index) == g_EntityFactory;
	}

	public static void Initialize()
	{
		Initialize();
	}
}

static void Initialize()
{
	g_EntityFactory = new CEntityFactory("sf2_trigger_boss_despawn", OnCreate);
	g_EntityFactory.DeriveFromClass("trigger_multiple");

	g_EntityFactory.BeginDataMapDesc()
		.DefineOutput("OnDespawn")
	.EndDataMapDesc();

	g_EntityFactory.Install();
}

static void OnCreate(int entity)
{
	SDKHook(entity, SDKHook_SpawnPost, OnSpawn);
	SDKHook(entity, SDKHook_StartTouchPost, OnStartTouchPost);
}

static void OnSpawn(int entity) 
{
	int spawnFlags = GetEntProp(entity, Prop_Data, "m_spawnflags");
	SetEntProp(entity, Prop_Data, "m_spawnflags", spawnFlags | TRIGGER_NPCS);
}

static void OnStartTouchPost(int entity, int toucher)
{
	if (!g_Enabled)
	{
		return;
	}

	SF2TriggerBossDespawnEntity thisEnt = SF2TriggerBossDespawnEntity(entity);

	if (thisEnt.PassesTriggerFilters(toucher))
	{
		int bossIndex = NPCGetFromEntIndex(toucher);
		if (bossIndex != -1) 
		{
			thisEnt.FireOutput("OnDespawn", toucher);
			RemoveSlender(bossIndex);
		}
	}
}