#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <tf2items>
#include <tf2attributes>
#include <dhooks>
#include <nativevotes>
#include <collisionhook>
#include <cbasenpc>
#include <cbasenpc/util>

#pragma semicolon 1

#include <tf2>
#include <tf2_stocks>
#include <morecolors>

#undef REQUIRE_PLUGIN
#include <adminmenu>
#tryinclude <store/store-tf2footprints>
#tryinclude <store>
#define REQUIRE_PLUGIN

#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#tryinclude <steamworks>
bool steamtools;
bool steamworks;
#define REQUIRE_EXTENSIONS

#define DEBUG
#define SF2

#include <sf2>
#pragma newdecls required

#define PLUGIN_VERSION "1.7.3.1 M"
#define PLUGIN_VERSION_DISPLAY "1.7.3.1 M"

#define TFTeam_Spectator 1
#define TFTeam_Red 2
#define TFTeam_Blue 3
#define TFTeam_Boss 5

#define MASK_RED 33640459
#define MASK_BLUE 33638411

#define EF_ITEM_BLINK 0x100


public Plugin myinfo = 
{
	name = "Slender Fortress", 
	author = "KitRifty, Kenzzer, Mentrillum, The Gaben", 
	description = "Based on the game Slender: The Eight Pages.", 
	version = PLUGIN_VERSION, 
	url = "https://discord.gg/7Zz7RYTCC4"
}

#define FILE_RESTRICTEDWEAPONS "configs/sf2/restrictedweapons.cfg"
#define FILE_RESTRICTEDWEAPONS_DATA "data/sf2/restrictedweapons.cfg"

#define BOSS_THINKRATE 0.1 // doesn't really matter much since timers go at a minimum of 0.1 seconds anyways

#define CRIT_SOUND "player/crit_hit.wav"
#define CRIT_PARTICLENAME "crit_text"
#define MINICRIT_SOUND "player/crit_hit_mini.wav"
#define MINICRIT_PARTICLENAME "minicrit_text"
#define ZAP_SOUND "weapons/barret_arm_zap.wav"
#define ZAP_PARTICLENAME "dxhr_arm_muzzleflash"
#define FIREWORKSBLU_PARTICLENAME "utaunt_firework_teamcolor_blue"
#define FIREWORKSRED_PARTICLENAME "utaunt_firework_teamcolor_red"
#define TELEPORTEDINBLU_PARTICLENAME "teleported_red"
#define SOUND_THUNDER "ambient/explosions/explode_9.wav"

#define EXPLOSIVEDANCE_EXPLOSION1 "weapons/explode1.wav"
#define EXPLOSIVEDANCE_EXPLOSION2 "weapons/explode2.wav"
#define EXPLOSIVEDANCE_EXPLOSION3 "weapons/explode3.wav"

#define SPECIAL1UPSOUND "mvm/mvm_revive.wav"

#define SPECIALROUND_BOO_DISTANCE 120.0
#define SPECIALROUND_BOO_DURATION 4.0

#define PAGE_DETECTOR_BEEP "items/cart_explode_trigger.wav"

#define PAGE_MODEL "models/slender/pickups/sheet.mdl"
#define PAGE_MODELSCALE 1.0

#define DEFAULT_CLOAKONSOUND "weapons/medi_shield_deploy.wav"
#define DEFAULT_CLOAKOFFSOUND "weapons/medi_shield_retract.wav"

#define SF_KEYMODEL "models/demani_sf/key_australium.mdl"

#define FLASHLIGHT_CLICKSOUND "slender/slenderflashlightclick.wav"
#define FLASHLIGHT_CLICKSOUND_NIGHTVISION "slender/nightvision.mp3"
#define FLASHLIGHT_BREAKSOUND "ambient/energy/spark6.wav"
#define FLASHLIGHT_NOSOUND "player/suit_denydevice.wav"
#define PAGE_GRABSOUND "slender/slenderpagegrab.wav"
#define TWENTYDOLLARS_MUSIC "slender/gimm20dollars_v2.wav"

#define MUSIC_CHAN SNDCHAN_AUTO
#define MUSIC_GOTPAGES1_SOUND "slender/newambience_1.wav"
#define MUSIC_GOTPAGES2_SOUND "slender/newambience_2.wav"
#define MUSIC_GOTPAGES3_SOUND "slender/newambience_3.wav"
#define MUSIC_GOTPAGES4_SOUND "slender/newambience_4.wav"
#define MUSIC_PAGE_VOLUME 1.0

#define SF2_INTRO_DEFAULT_MUSIC "slender/intro.mp3"

#define PROXY_RAGE_MODE_SOUND "slender/proxyrage.mp3"

#define FIREBALL_SHOOT "misc/halloween/spell_fireball_cast.wav"
#define FIREBALL_IMPACT "misc/halloween/spell_fireball_impact.wav"
#define FIREBALL_TRAIL "spell_fireball_small_red"
#define ICEBALL_IMPACT "weapons/icicle_freeze_victim_01.wav"
#define ICEBALL_TRAIL "spell_fireball_small_blue"
#define ROCKET_SHOOT "weapons/rocket_shoot.wav"
#define ROCKET_IMPACT "weapons/explode1.wav"
#define ROCKET_MODEL "models/weapons/w_models/w_rocket.mdl"
#define ROCKET_TRAIL "rockettrail"
#define ROCKET_EXPLODE_PARTICLE "ExplosionCore_MidAir"
#define GRENADE_SHOOT "weapons/grenade_launcher_shoot.wav"
#define SENTRYROCKET_SHOOT "weapons/sentry_rocket.wav"
#define ARROW_SHOOT "weapons/bow_shoot.wav"
#define GRENADE_MODEL "models/weapons/w_models/w_grenade_grenadelauncher.mdl"
#define MANGLER_SHOOT "weapons/cow_mangler_main_shot.wav"
#define MANGLER_EXPLODE1 "weapons/cow_mangler_explosion_normal_01.wav"
#define MANGLER_EXPLODE2 "weapons/cow_mangler_explosion_normal_02.wav"
#define MANGLER_EXPLODE3 "weapons/cow_mangler_explosion_normal_03.wav"
#define BASEBALL_SHOOT "weapons/bat_baseball_hit1.wav"
#define BASEBALL_MODEL "weapons/w_models/w_baseball.mdl"

#define JARATE_HITPLAYER "weapons/jar_single.wav"
#define JARATE_PARTICLE "peejar_impact"
#define MILK_PARTICLE "peejar_impact_milk"
#define GAS_PARTICLE "gas_can_impact_blue"
#define STUN_HITPLAYER "weapons/icicle_freeze_victim_01.wav"
#define STUN_PARTICLE "xms_icicle_melt"
#define ELECTRIC_RED_PARTICLE "electrocuted_gibbed_red"
#define ELECTRIC_BLUE_PARTICLE "electrocuted_gibbed_red"

//Page Rewards
#define EXPLODE_PLAYER "items/pumpkin_explode1.wav"
#define UBER_ROLL "misc/halloween/spell_overheal.wav"
#define NO_EFFECT_ROLL "player/taunt_sorcery_fail.wav"
#define BLEED_ROLL "items/powerup_pickup_plague_infected.wav"
#define CRIT_ROLL "items/powerup_pickup_crits.wav"
#define LOSE_SPRINT_ROLL "misc/banana_slip.wav"
#define JARATE_ROLL "weapons/jar_explode.wav"
#define GAS_ROLL "weapons/gas_can_explode.wav"

#define FIREWORK_EXPLOSION	"weapons/flare_detonator_explode.wav"
#define FIREWORK_START "weapons/flare_detonator_launch.wav"
#define FIREWORK_PARTICLE	"burningplayer_rainbow_flame"

#define GENERIC_ROLL_TICK_1 "ui/buttonrollover.wav"
#define GENERIC_ROLL_TICK_2 "ui/buttonrollover.wav"

#define MINICRIT_BUFF "weapons/buff_banner_flag.wav"

#define HYPERSNATCHER_NIGHTAMRE_1 "slender/snatcher/nightmare1.wav"
#define HYPERSNATCHER_NIGHTAMRE_2 "slender/snatcher/nightmare2.wav"
#define HYPERSNATCHER_NIGHTAMRE_3 "slender/snatcher/nightmare3.wav"
#define HYPERSNATCHER_NIGHTAMRE_4 "slender/snatcher/nightmare4.wav"
#define HYPERSNATCHER_NIGHTAMRE_5 "slender/snatcher/nightmare5.wav"
#define SNATCHER_APOLLYON_1 "slender/snatcher/apollyon1.wav"
#define SNATCHER_APOLLYON_2 "slender/snatcher/apollyon2.wav"
#define SNATCHER_APOLLYON_3 "slender/snatcher/apollyon3.wav"

#define RENEVANT_MAXWAVES 5

#define NULLSOUND "misc/null.wav"

#define NINETYSMUSIC "slender/sf2modified_runninginthe90s_v2.wav"
#define TRIPLEBOSSESMUSIC "slender/sf2modified_triplebosses_v2.wav"

#define TRAP_DEPLOY "slender/modified_traps/beartrap/trap_deploy.mp3"
#define TRAP_CLOSE "slender/modified_traps/beartrap/trap_close.mp3"
#define TRAP_MODEL "models/mentrillum/traps/beartrap.mdl"

#define LASER_MODEL "sprites/laser.vmt"
int g_LaserIndex;

#define THANATOPHOBIA_MEDICNO "vo/medic_no03.mp3"

#define SF2_HUD_TEXT_COLOR_R 127
#define SF2_HUD_TEXT_COLOR_G 167
#define SF2_HUD_TEXT_COLOR_B 141
#define SF2_HUD_TEXT_COLOR_A 255

enum struct MuteMode
{
	int MuteMode_Normal;
	int MuteMode_DontHearOtherTeam;
	int MuteMode_DontHearOtherTeamIfNotProxy;
}

enum struct FlashlightTemperature
{
	int FlashlightTemperature_6000;
	int FlashlightTemperature_1000;
	int FlashlightTemperature_2000;
	int FlashlightTemperature_3000;
	int FlashlightTemperature_4000;
	int FlashlightTemperature_5000;
	int FlashlightTemperature_7000;
	int FlashlightTemperature_8000;
	int FlashlightTemperature_9000;
	int FlashlightTemperature_10000;
}

char g_strSoundNightmareMode[][] = 
{
	"ambient/halloween/thunder_04.wav", 
	"ambient/halloween/thunder_05.wav", 
	"ambient/halloween/thunder_08.wav", 
	"ambient/halloween/mysterious_perc_09.wav", 
	"ambient/halloween/mysterious_perc_09.wav", 
	"ambient/halloween/windgust_08.wav"
};

static const char g_sPageCollectDuckSounds[][] = 
{
	"ambient/bumper_car_quack1.wav", 
	"ambient/bumper_car_quack2.wav", 
	"ambient/bumper_car_quack3.wav", 
	"ambient/bumper_car_quack4.wav", 
	"ambient/bumper_car_quack5.wav", 
	"ambient/bumper_car_quack9.wav", 
	"ambient/bumper_car_quack11.wav"
};

//Update
bool g_SeeUpdateMenu[MAXPLAYERS + 1] = false;
//Command
bool g_PlayerNoPoints[MAXPLAYERS + 1] = false;
bool g_AdminNoPoints[MAXPLAYERS + 1] = false;
bool g_AdminAllTalk[MAXPLAYERS + 1] = false;

// Offsets.
int g_PlayerFOVOffset = -1;
int g_PlayerDefaultFOVOffset = -1;
int g_PlayerFogCtrlOffset = -1;
int g_PlayerPunchAngleOffset = -1;
int g_PlayerPunchAngleOffsetVel = -1;
int g_FogCtrlEnableOffset = -1;
int g_FogCtrlEndOffset = -1;
int g_CollisionGroupOffset = -1;
int g_FullDamageData = -1;

//Commands
float g_LastCommandTime[MAXPLAYERS + 1];

bool g_Enabled;

KeyValues g_Config;
KeyValues g_RestrictedWeaponsConfig;
KeyValues g_SpecialRoundsConfig;

ArrayList g_PageMusicRanges;
int g_PageMusicActiveIndex[MAXPLAYERS + 1] = { -1, ... };

int g_SlenderModel[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
int g_SlenderCopyMaster[MAX_BOSSES] = { -1, ... };
int g_SlenderMaxCopies[MAX_BOSSES][Difficulty_Max];
int g_SlenderCompanionMaster[MAX_BOSSES] = { -1, ... };
float g_SlenderEyePosOffset[MAX_BOSSES][3];
float g_SlenderEyeAngOffset[MAX_BOSSES][3];
float g_SlenderDetectMins[MAX_BOSSES][3];
float g_SlenderDetectMaxs[MAX_BOSSES][3];
int g_SlenderRenderColor[MAX_BOSSES][4];
int g_SlenderRenderFX[MAX_BOSSES];
int g_SlenderRenderMode[MAX_BOSSES];
Handle g_SlenderThink[MAX_BOSSES];
Handle g_SlenderEntityThink[MAX_BOSSES];
Handle g_SlenderFakeTimer[MAX_BOSSES];
Handle g_SlenderDeathCamTimer[MAX_BOSSES];
int g_SlenderDeathCamTarget[MAX_BOSSES];
float g_SlenderLastKill[MAX_BOSSES];
int g_SlenderState[MAX_BOSSES];
int g_SlenderHitbox[MAX_BOSSES];
int g_SlenderHitboxOwner[2049] = { INVALID_ENT_REFERENCE, ... };
int g_SlenderTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
bool g_SlenderTargetIsVisible[MAX_BOSSES] = false;
bool g_SlenderSpawning[MAX_BOSSES] = false;
float g_SlenderAcceleration[MAX_BOSSES][Difficulty_Max];
float g_SlenderGoalPos[MAX_BOSSES][3];
float g_SlenderStaticRadius[MAX_BOSSES][Difficulty_Max];
float g_SlenderStaticRate[MAX_BOSSES][Difficulty_Max];
float g_SlenderStaticRateDecay[MAX_BOSSES][Difficulty_Max];
float g_SlenderStaticGraceTime[MAX_BOSSES][Difficulty_Max];
float g_SlenderChaseDeathPosition[MAX_BOSSES][3];
bool g_SlenderChaseDeathPositionBool[MAX_BOSSES];

bool g_SlenderDeathCamScareSound[MAX_BOSSES];
bool g_SlenderPublicDeathCam[MAX_BOSSES];
float g_SlenderPublicDeathCamSpeed[MAX_BOSSES];
float g_SlenderPublicDeathCamAcceleration[MAX_BOSSES];
float g_SlenderPublicDeathCamDeceleration[MAX_BOSSES];
float g_SlenderPublicDeathCamBackwardOffset[MAX_BOSSES];
float g_SlenderPublicDeathCamDownwardOffset[MAX_BOSSES];
bool g_SlenderDeathCamOverlay[MAX_BOSSES];
float g_SlenderDeathCamOverlayTimeStart[MAX_BOSSES];
float g_SlenderDeathCamTime[MAX_BOSSES];

//The Gaben's stuff
bool g_bSlenderHasBurnKillEffect[MAX_BOSSES];
bool g_bSlenderHasCloakKillEffect[MAX_BOSSES];
bool g_bSlenderHasDecapKillEffect[MAX_BOSSES];
bool g_bSlenderHasGibKillEffect[MAX_BOSSES];
bool g_bSlenderHasGoldKillEffect[MAX_BOSSES];
bool g_bSlenderHasIceKillEffect[MAX_BOSSES];
bool g_bSlenderHasElectrocuteKillEffect[MAX_BOSSES];
bool g_bSlenderHasAshKillEffect[MAX_BOSSES];
bool g_bSlenderHasDeleteKillEffect[MAX_BOSSES];
bool g_bSlenderHasPushRagdollOnKill[MAX_BOSSES];
bool g_bSlenderHasDissolveRagdollOnKill[MAX_BOSSES];
int g_iSlenderDissolveRagdollType[MAX_BOSSES];
bool g_bSlenderHasPlasmaRagdollOnKill[MAX_BOSSES];
bool g_bSlenderHasResizeRagdollOnKill[MAX_BOSSES];
float g_SlenderResizeRagdollHands[MAX_BOSSES];
float g_SlenderResizeRagdollHead[MAX_BOSSES];
float g_SlenderResizeRagdollTorso[MAX_BOSSES];
bool g_SlenderCustomOutroSong[MAX_BOSSES];
bool g_bSlenderHasDecapOrGibKillEffect[MAX_BOSSES];
bool g_bSlenderHasSilentKill[MAX_BOSSES];
bool g_bSlenderHasMultiKillEffect[MAX_BOSSES];
bool g_bSlenderPlayerCustomDeathFlag[MAX_BOSSES];
int g_iSlenderPlayerSetDeathFlag[MAX_BOSSES];

bool g_SlenderUseCustomOutlines[MAX_BOSSES];
int g_SlenderOutlineColorR[MAX_BOSSES];
int g_SlenderOutlineColorG[MAX_BOSSES];
int g_SlenderOutlineColorB[MAX_BOSSES];
int g_SlenderOutlineTransparency[MAX_BOSSES];
bool g_SlenderUseRainbowOutline[MAX_BOSSES];
float g_SlenderRainbowCycleRate[MAX_BOSSES];

int g_ProjectileFlags[2049] = { 0, ... };
int g_TrapEntityCount;
float g_RoundTimeMessage = 0.0;

char g_SlenderCloakOnSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderCloakOffSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderJarateHitSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderMilkHitSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderGasHitSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderStunHitSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderFireballExplodeSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderFireballShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderFireballTrail[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderIceballImpactSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderIceballTrail[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderRocketExplodeSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderRocketShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderRocketModel[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderRocketTrailParticle[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderRocketExplodeParticle[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderGrenadeShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderSentryRocketShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderArrowShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderManglerShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderBaseballShootSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderEngineSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderShockwaveBeamSprite[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderShockwaveHaloSprite[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderSmiteSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_sSlenderTrapModel[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderTrapDeploySound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderTrapMissSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderTrapHitSound[MAX_BOSSES][PLATFORM_MAX_PATH];
char g_SlenderTrapAnimIdle[MAX_BOSSES][65];
char g_SlenderTrapAnimOpen[MAX_BOSSES][65];
char g_SlenderTrapAnimClose[MAX_BOSSES][65];

int g_SlenderTeleportTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
int g_SlenderProxyTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
bool g_SlenderTeleportTargetIsCamping[MAX_BOSSES] = false;

float g_SlenderNextTeleportTime[MAX_BOSSES] = { -1.0, ... };
float g_SlenderTeleportTargetTime[MAX_BOSSES] = { -1.0, ... };
float g_SlenderTeleportMinRange[MAX_BOSSES][Difficulty_Max];
float g_SlenderTeleportMaxRange[MAX_BOSSES][Difficulty_Max];
float g_SlenderTeleportMaxTargetTime[MAX_BOSSES] = { -1.0, ... };
float g_SlenderTeleportMaxTargetStress[MAX_BOSSES] = { 0.0, ... };
float g_SlenderTeleportPlayersRestTime[MAX_BOSSES][MAXPLAYERS + 1];
bool g_bSlenderTeleportIgnoreChases[MAX_BOSSES];
bool g_bSlenderTeleportIgnoreVis[MAX_BOSSES];

bool g_SlenderInDeathcam[MAX_BOSSES] = false;

bool g_SlenderProxiesAllowNormalVoices[MAX_BOSSES];

int g_SlenderBoxingBossCount = 0;
int g_SlenderBoxingBossKilled = 0;
bool g_SlenderBoxingBossIsKilled[MAX_BOSSES] = false;

//The global timer replacing OnGameFrame()
Handle g_OnGameFrameTimer = null;

// For boss type 2
// General variables
PathFollower g_BossPathFollower[MAX_BOSSES];
bool g_IsSlenderAttacking[MAX_BOSSES];
bool g_SlenderGiveUp[MAX_BOSSES];
Handle g_SlenderAttackTimer[MAX_BOSSES];
Handle g_SlenderLaserTimer[MAX_BOSSES];
Handle g_SlenderBackupAtkTimer[MAX_BOSSES];
Handle g_SlenderChaseInitialTimer[MAX_BOSSES];
Handle g_SlenderRage1Timer[MAX_BOSSES];
Handle g_SlenderRage2Timer[MAX_BOSSES];
Handle g_SlenderRage3Timer[MAX_BOSSES];
Handle g_SlenderSpawnTimer[MAX_BOSSES];
Handle g_SlenderHealTimer[MAX_BOSSES];
Handle g_SlenderHealDelayTimer[MAX_BOSSES];
Handle g_SlenderHealEventTimer[MAX_BOSSES];
Handle g_SlenderStartFleeTimer[MAX_BOSSES];

int g_SlenderInterruptConditions[MAX_BOSSES];
float g_SlenderLastFoundPlayer[MAX_BOSSES][MAXPLAYERS + 1];
float g_SlenderLastFoundPlayerPos[MAX_BOSSES][MAXPLAYERS + 1][3];
float g_SlenderNextPathTime[MAX_BOSSES] = { -1.0, ... };
float g_SlenderLastCalculPathTime[MAX_BOSSES] = { -1.0, ... };
float g_SlenderCalculatedWalkSpeed[MAX_BOSSES];
float g_SlenderCalculatedSpeed[MAX_BOSSES];
float g_SlenderCalculatedAcceleration[MAX_BOSSES];
float g_SlenderCalculatedMaxWalkSpeed[MAX_BOSSES];
float g_SlenderCalculatedMaxSpeed[MAX_BOSSES];
float g_SlenderSpeedMultiplier[MAX_BOSSES];
float g_SlenderTimeUntilNoPersistence[MAX_BOSSES];
int g_SlenderTauntAlertCount[MAX_BOSSES];

float g_SlenderProxyTeleportMinRange[MAX_BOSSES][Difficulty_Max];
float g_SlenderProxyTeleportMaxRange[MAX_BOSSES][Difficulty_Max];

// Sound variables
float g_SlenderTargetSoundLastTime[MAX_BOSSES] = { -1.0, ... };
SoundType g_SlenderTargetSoundType[MAX_BOSSES] = { SoundType_None, ... };
float g_SlenderTargetSoundMasterPos[MAX_BOSSES][3]; // to determine hearing focus
float g_SlenderTargetSoundTempPos[MAX_BOSSES][3];
float g_SlenderTargetSoundDiscardMasterPosTime[MAX_BOSSES];
bool g_SlenderInvestigatingSound[MAX_BOSSES];
int g_SlenderTargetSoundCount[MAX_BOSSES];
int g_SlenderAutoChaseCount[MAX_BOSSES];
float g_SlenderAutoChaseCooldown[MAX_BOSSES];
int g_SlenderSoundTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
int g_SlenderSeeTarget[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
bool g_SlenderIsAutoChasingLoudPlayer[MAX_BOSSES];
float g_SlenderLastHeardVoice[MAX_BOSSES];
float g_SlenderLastHeardFootstep[MAX_BOSSES];
float g_SlenderLastHeardWeapon[MAX_BOSSES];

float g_SlenderNextStunTime[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextJumpScare[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextVoiceSound[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextMoanSound[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextWanderPos[MAX_BOSSES][Difficulty_Max];
float g_SlenderNextCloakTime[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextTrapPlacement[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextFootstepIdleSound[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextFootstepWalkSound[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextFootstepRunSound[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextFootstepStunSound[MAX_BOSSES] = { -1.0, ... };
float g_SlenderNextFootstepAttackSound[MAX_BOSSES] = { -1.0, ... };

float g_SlenderIdleFootstepTime[MAX_BOSSES];
float g_SlenderWalkFootstepTime[MAX_BOSSES];
float g_SlenderRunFootstepTime[MAX_BOSSES];
float g_SlenderStunFootstepTime[MAX_BOSSES];
float g_SlenderAttackFootstepTime[MAX_BOSSES];

float g_SlenderTimeUntilRecover[MAX_BOSSES] = { -1.0, ... };
float g_SlenderTimeUntilAlert[MAX_BOSSES] = { -1.0, ... };
float g_SlenderTimeUntilIdle[MAX_BOSSES] = { -1.0, ... };
float g_SlenderTimeUntilChase[MAX_BOSSES] = { -1.0, ... };
float g_SlenderTimeUntilKill[MAX_BOSSES] = { -1.0, ... };
float g_SlenderTimeUntilNextProxy[MAX_BOSSES] = { -1.0, ... };
float g_SlenderTimeUntilAttackEnd[MAX_BOSSES] = { -1.0, ... };

float g_SlenderProxyDamageVsEnemy[MAX_BOSSES][Difficulty_Max];
float g_SlenderProxyDamageVsBackstab[MAX_BOSSES][Difficulty_Max];
float g_SlenderProxyDamageVsSelf[MAX_BOSSES][Difficulty_Max];
int g_SlenderProxyControlGainHitEnemy[MAX_BOSSES][Difficulty_Max];
int g_SlenderProxyControlGainHitByEnemy[MAX_BOSSES][Difficulty_Max];
float g_SlenderProxyControlDrainRate[MAX_BOSSES][Difficulty_Max];
int g_SlenderMaxProxies[MAX_BOSSES][Difficulty_Max];

int g_SlenderProxyHurtChannel[MAX_BOSSES];
int g_SlenderProxyHurtLevel[MAX_BOSSES];
int g_SlenderProxyHurtFlags[MAX_BOSSES];
float g_SlenderProxyHurtVolume[MAX_BOSSES];
int g_SlenderProxyHurtPitch[MAX_BOSSES];
int g_iSlenderProxyDeathChannel[MAX_BOSSES];
int g_iSlenderProxyDeathLevel[MAX_BOSSES];
int g_iSlenderProxyDeathFlags[MAX_BOSSES];
float g_SlenderProxyDeathVolume[MAX_BOSSES];
int g_iSlenderProxyDeathPitch[MAX_BOSSES];
int g_SlenderProxyIdleChannel[MAX_BOSSES];
int g_SlenderProxyIdleLevel[MAX_BOSSES];
int g_SlenderProxyIdleFlags[MAX_BOSSES];
float g_SlenderProxyIdleVolume[MAX_BOSSES];
int g_SlenderProxyIdlePitch[MAX_BOSSES];
float g_SlenderProxyIdleCooldownMin[MAX_BOSSES];
float g_SlenderProxyIdleCooldownMax[MAX_BOSSES];
int g_SlenderProxySpawnChannel[MAX_BOSSES];
int g_SlenderProxySpawnLevel[MAX_BOSSES];
int g_SlenderProxySpawnFlags[MAX_BOSSES];
float g_SlenderProxySpawnVolume[MAX_BOSSES];
int g_SlenderProxySpawnPitch[MAX_BOSSES];

bool g_SlenderInBacon[MAX_BOSSES];

bool g_bSlenderDifficultyAnimations[MAX_BOSSES];

int g_NightvisionType = 0;

//Healthbar
int g_HealthBar;

// Page data.
enum struct SF2PageEntityData
{
	int EntRef;
	char CollectSound[PLATFORM_MAX_PATH];
	int CollectSoundPitch;
}

ArrayList g_Pages;
int g_PageCount;
int g_PageMax;
float g_PageFoundLastTime;
bool g_PageRef;
char g_PageRefModelName[PLATFORM_MAX_PATH];
float g_PageRefModelScale;

static Handle g_PlayerIntroMusicTimer[MAXPLAYERS + 1] = { null, ... };

// Seeing Mr. Slendy data.

float g_LastVisibilityProcess[MAXPLAYERS + 1];
bool g_PlayerSeesSlender[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerSeesSlenderLastTime[MAXPLAYERS + 1][MAX_BOSSES];

float g_flPlayerSightSoundNextTime[MAXPLAYERS + 1][MAX_BOSSES];

float g_flPlayerScareLastTime[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerScareNextTime[MAXPLAYERS + 1][MAX_BOSSES];
float g_PlayerStaticAmount[MAXPLAYERS + 1];

int g_NpcPlayerScareVictin[MAX_BOSSES] = { INVALID_ENT_REFERENCE, ... };
bool g_NpcChasingScareVictin[MAX_BOSSES];
bool g_NpcLostChasingScareVictim[MAX_BOSSES];
bool g_PlayerScaredByBoss[MAXPLAYERS + 1][MAX_BOSSES];

bool g_NpcVelocityCancel[MAX_BOSSES];

//Boxing data
Handle g_SlenderBurnTimer[MAX_BOSSES];
Handle g_SlenderBleedTimer[MAX_BOSSES];
Handle g_SlenderMarkedTimer[MAX_BOSSES];
float g_SlenderStopBurningTimer[MAX_BOSSES];
float g_SlenderStopBleedingTimer[MAX_BOSSES];
bool g_SlenderIsBurning[MAX_BOSSES]; //This is for the Sun-on-a-Stick
bool g_SlenderIsMarked[MAX_BOSSES]; //For mini-crits and Bushwacka
int g_PlayerHitsToCrits[MAXPLAYERS + 1];
int g_PlayerHitsToHeads[MAXPLAYERS + 1];

static bool g_PlayersAreCritted = false;
static bool g_PlayersAreMiniCritted = false;

bool g_PlayerIn1UpCondition[MAXPLAYERS + 1];
bool g_PlayerDied1Up[MAXPLAYERS + 1];
bool g_bPlayerFullyDied1Up[MAXPLAYERS + 1];

float g_PlayerLastChaseBossEncounterTime[MAXPLAYERS + 1][MAX_BOSSES];

// Player static data.
int g_iPlayerStaticMode[MAXPLAYERS + 1][MAX_BOSSES];
float g_flPlayerStaticIncreaseRate[MAXPLAYERS + 1];
float g_flPlayerStaticDecreaseRate[MAXPLAYERS + 1];
Handle g_PlayerStaticTimer[MAXPLAYERS + 1];
int g_PlayerStaticMaster[MAXPLAYERS + 1] = { -1, ... };
char g_PlayerStaticSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char g_PlayerLastStaticSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerLastStaticTime[MAXPLAYERS + 1];
float g_flPlayerLastStaticVolume[MAXPLAYERS + 1];
Handle g_hPlayerLastStaticTimer[MAXPLAYERS + 1];

// Static shake data.
int g_iPlayerStaticShakeMaster[MAXPLAYERS + 1];
bool g_bPlayerInStaticShake[MAXPLAYERS + 1];
char g_PlayerStaticShakeSound[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_flPlayerStaticShakeMinVolume[MAXPLAYERS + 1];
float g_flPlayerStaticShakeMaxVolume[MAXPLAYERS + 1];

float g_PlayerProxyNextVoiceSound[MAXPLAYERS + 1];

bool g_PlayerTrapped[MAXPLAYERS + 1];
int g_PlayerTrapCount[MAXPLAYERS + 1];

int g_iPlayerBossKillSubject[MAXPLAYERS + 1];

// Difficulty
bool g_PlayerCalledForNightmare[MAXPLAYERS + 1];
bool g_InProxySurvivalRageMode = false;

int g_PlayerRandomClassNumber[MAXPLAYERS + 1];

// Hint data.
enum
{
	PlayerHint_Sprint = 0, 
	PlayerHint_Flashlight, 
	PlayerHint_MainMenu, 
	PlayerHint_Blink, 
	PlayerHint_Trap, 
	PlayerHint_MaxNum
};

enum struct PlayerPreferences
{
	bool PlayerPreference_PvPAutoSpawn;
	bool PlayerPreference_FilmGrain;
	bool PlayerPreference_ShowHints;
	bool PlayerPreference_EnableProxySelection;
	bool PlayerPreference_ProxyShowMessage;
	bool PlayerPreference_ProjectedFlashlight;
	bool PlayerPreference_ViewBobbing;
	bool PlayerPreference_GroupOutline;
	bool PlayerPreference_PvPSpawnProtection;
	bool PlayerPreference_LegacyHud;
	
	int PlayerPreference_MuteMode; //0 = Normal, 1 = Opposing Team, 2 = Opposing Team Proxy Ignore
	int PlayerPreference_FlashlightTemperature; //1 = 1000, 2 = 2000, 3 = 3000, 4 = 4000, 5 = 5000, 6 = 6000, 7 = 7000, 8 = 8000, 9 = 9000, 10 = 10000
	int PlayerPreference_GhostModeToggleState; //0 = Nothing, 1 = Ghost on grace end, 2 = Ghost on death
	int PlayerPreference_GhostModeTeleportState; //0 = Players, 1 = Bosses
	
}

bool g_PlayerHints[MAXPLAYERS + 1][PlayerHint_MaxNum];
PlayerPreferences g_PlayerPreferences[MAXPLAYERS + 1];

//Particle data.
enum
{
	CriticalHit = 0, 
	MiniCritHit, 
	ZapParticle, 
	FireworksRED, 
	FireworksBLU, 
	TeleportedInBlu, 
	MaxParticle
};

int g_Particles[MaxParticle] = -1;

// Player data.
bool g_PlayerIsExitCamping[MAXPLAYERS + 1];
int g_iPlayerLastButtons[MAXPLAYERS + 1];
bool g_bPlayerChoseTeam[MAXPLAYERS + 1];
bool g_PlayerEliminated[MAXPLAYERS + 1];
bool g_PlayerHasRegenerationItem[MAXPLAYERS + 1];
bool g_PlayerEscaped[MAXPLAYERS + 1];
int g_PlayerPageCount[MAXPLAYERS + 1];
int g_iPlayerQueuePoints[MAXPLAYERS + 1];
bool g_bPlayerPlaying[MAXPLAYERS + 1];
bool g_PlayerBackStabbed[MAXPLAYERS + 1];
Handle g_hPlayerOverlayCheck[MAXPLAYERS + 1];

Handle g_hPlayerSwitchBlueTimer[MAXPLAYERS + 1];

// Player stress data.
float g_PlayerStressAmount[MAXPLAYERS + 1];
float g_PlayerStressNextUpdateTime[MAXPLAYERS + 1];

// Proxy data.
bool g_PlayerProxy[MAXPLAYERS + 1];
bool g_bPlayerProxyAvailable[MAXPLAYERS + 1];
Handle g_hPlayerProxyAvailableTimer[MAXPLAYERS + 1];
bool g_bPlayerProxyAvailableInForce[MAXPLAYERS + 1];
int g_PlayerProxyAvailableCount[MAXPLAYERS + 1];
int g_PlayerProxyMaster[MAXPLAYERS + 1];
int g_PlayerProxyControl[MAXPLAYERS + 1];
Handle g_PlayerProxyControlTimer[MAXPLAYERS + 1];
float g_PlayerProxyControlRate[MAXPLAYERS + 1];
Handle g_PlayerProxyVoiceTimer[MAXPLAYERS + 1];
int g_PlayerProxyAskMaster[MAXPLAYERS + 1] = { -1, ... };
float g_PlayerProxyAskPosition[MAXPLAYERS + 1][3];
int g_PlayerProxyAskSpawnPoint[MAXPLAYERS + 1] = { -1, ... };

int g_PlayerDesiredFOV[MAXPLAYERS + 1];

Handle g_hPlayerPostWeaponsTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_PlayerIgniteTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_PlayerResetIgnite[MAXPLAYERS + 1] = { null, ... };
Handle g_hPlayerPageRewardTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_hPlayerPageRewardCycleTimer[MAXPLAYERS + 1] = { null, ... };
Handle g_hPlayerFireworkTimer[MAXPLAYERS + 1] = { null, ... };

bool g_bPlayerGettingPageReward[MAXPLAYERS + 1] = false;

// Music system.
int g_PlayerMusicFlags[MAXPLAYERS + 1];
char g_PlayerMusicString[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_PlayerMusicVolume[MAXPLAYERS + 1];
float g_PlayerMusicTargetVolume[MAXPLAYERS + 1];
Handle g_PlayerMusicTimer[MAXPLAYERS + 1];
int g_PlayerPageMusicMaster[MAXPLAYERS + 1];

// Chase music system, which apparently also uses the alert song system. And the idle sound system.
char g_PlayerChaseMusicString[MAXPLAYERS + 1][MAX_BOSSES][PLATFORM_MAX_PATH];
char g_PlayerChaseMusicSeeString[MAXPLAYERS + 1][MAX_BOSSES][PLATFORM_MAX_PATH];
float g_PlayerChaseMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
float g_PlayerChaseMusicSeeVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_PlayerChaseMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_PlayerChaseMusicSeeTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_PlayerChaseMusicMaster[MAXPLAYERS + 1] = { -1, ... };
int g_PlayerChaseMusicSeeMaster[MAXPLAYERS + 1] = { -1, ... };
int g_PlayerChaseMusicOldMaster[MAXPLAYERS + 1] = { -1, ... };
int g_PlayerChaseMusicSeeOldMaster[MAXPLAYERS + 1] = { -1, ... };

char g_PlayerAlertMusicString[MAXPLAYERS + 1][MAX_BOSSES][PLATFORM_MAX_PATH];
float g_PlayerAlertMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_PlayerAlertMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_PlayerAlertMusicMaster[MAXPLAYERS + 1] = { -1, ... };
int g_PlayerAlertMusicOldMaster[MAXPLAYERS + 1] = { -1, ... };

char g_PlayerIdleMusicString[MAXPLAYERS + 1][MAX_BOSSES][PLATFORM_MAX_PATH];
float g_PlayerIdleMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_PlayerIdleMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_PlayerIdleMusicMaster[MAXPLAYERS + 1] = { -1, ... };
int g_PlayerIdleMusicOldMaster[MAXPLAYERS + 1] = { -1, ... };

char g_Player20DollarsMusicString[MAXPLAYERS + 1][MAX_BOSSES][PLATFORM_MAX_PATH];
float g_Player20DollarsMusicVolumes[MAXPLAYERS + 1][MAX_BOSSES];
Handle g_Player20DollarsMusicTimer[MAXPLAYERS + 1][MAX_BOSSES];
int g_Player20DollarsMusicMaster[MAXPLAYERS + 1] = { -1, ... };
int g_Player20DollarsMusicOldMaster[MAXPLAYERS + 1] = { -1, ... };


char g_Player90sMusicString[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_Player90sMusicVolumes[MAXPLAYERS + 1];
Handle g_Player90sMusicTimer[MAXPLAYERS + 1];


SF2RoundState g_iRoundState = SF2RoundState_Invalid;
float g_RoundDifficultyModifier = DIFFICULTYMODIFIER_NORMAL;
bool g_bRoundInfiniteFlashlight = false;
bool g_IsSurvivalMap = false;
bool g_IsRaidMap = false;
bool g_IsProxyMap = false;
bool g_BossesChaseEndlessly = false;
bool g_IsBoxingMap = false;
bool g_IsSlaughterRunMap = false;
bool g_bRoundInfiniteBlink = false;
bool g_IsRoundInfiniteSprint = false;

bool g_bRoundTimerPaused = false;
Handle g_hRoundGraceTimer = null;
Handle g_hRoundTimer = null;
Handle g_hVoteTimer = null;
static char g_strRoundBossProfile[SF2_MAX_PROFILE_NAME_LENGTH];
static char g_strRoundBoxingBossProfile[SF2_MAX_PROFILE_NAME_LENGTH];

int g_iRoundCount = 0;
int g_iRoundEndCount = 0;
int g_iRoundActiveCount = 0;
int g_RoundTime = 0;
int g_iSpecialRoundTime = 0;
int g_iTimeEscape = 0;
int g_RoundTimeLimit = 0;
int g_RoundEscapeTimeLimit = 0;
int g_RoundTimeGainFromPage = 0;
bool g_bRoundHasEscapeObjective = false;
bool g_RoundStopPageMusicOnEscape = false;

static int g_iRoundEscapePointEntity = INVALID_ENT_REFERENCE;

static int g_iRoundIntroFadeColor[4] = { 255, ... };
static float g_flRoundIntroFadeHoldTime;
static float g_flRoundIntroFadeDuration;
static Handle g_hRoundIntroTimer = null;
static bool g_bRoundIntroTextDefault = true;
static Handle g_hRoundIntroTextTimer = null;
static int g_iRoundIntroText;
char g_strRoundIntroMusic[PLATFORM_MAX_PATH] = "";
static char g_strPageCollectSound[PLATFORM_MAX_PATH] = "";
static int g_iPageSoundPitch = 100;
char currentMusicTrack[PLATFORM_MAX_PATH], currentMusicTrackNormal[PLATFORM_MAX_PATH], currentMusicTrackHard[PLATFORM_MAX_PATH], currentMusicTrackInsane[PLATFORM_MAX_PATH], currentMusicTrackNightmare[PLATFORM_MAX_PATH], currentMusicTrackApollyon[PLATFORM_MAX_PATH];

int g_iRoundWarmupRoundCount = 0;

bool g_bRoundWaitingForPlayers = false;

// Special round variables.
bool g_IsSpecialRound = false;

bool g_IsSpecialRoundNew = false;
bool g_IsSpecialRoundContinuous = false;
int g_iSpecialRoundCount = 1;
bool g_bPlayerPlayedSpecialRound[MAXPLAYERS + 1] = { true, ... };

// int boss round variables.
bool g_bNewBossRound = false;
static bool g_bNewBossRoundNew = false;
static bool g_bNewBossRoundContinuous = false;
static int g_iNewBossRoundCount = 1;

bool g_bPlayerPlayedNewBossRound[MAXPLAYERS + 1] = { true, ... };
static char g_strNewBossRoundProfile[64] = "";

static Handle g_hRoundMessagesTimer = null;
static int g_iRoundMessagesNum = 0;

static Handle g_hBossCountUpdateTimer = null;
Handle g_ClientAverageUpdateTimer = null;
static Handle g_hBlueNightvisionOutlineTimer = null;

// Server variables.
ConVar g_VersionConVar;
ConVar g_EnabledConVar;
ConVar g_SlenderMapsOnlyConVar;
ConVar g_PlayerViewbobEnabledConVar;
ConVar g_PlayerShakeEnabledConVar;
ConVar g_PlayerShakeFrequencyMaxConVar;
ConVar g_PlayerShakeAmplitudeMaxConVar;
ConVar g_GraceTimeConVar;
ConVar g_AllChatConVar;
ConVar g_20DollarsConVar;
ConVar g_MaxPlayersConVar;
ConVar g_MaxPlayersOverrideConVar;
ConVar g_CampingEnabledConVar;
ConVar g_CampingMaxStrikesConVar;
ConVar g_CampingStrikesWarnConVar;
ConVar g_ExitCampingTimeAllowedConVar;
ConVar g_CampingMinDistanceConVar;
ConVar g_CampingNoStrikeSanityConVar;
ConVar g_CampingNoStrikeBossDistanceConVar;
ConVar g_DifficultyConVar;
ConVar g_CameraOverlayConVar;
ConVar g_OverlayNoGrainConVar;
ConVar g_GhostOverlayConVar;
ConVar g_BossMainConVar;
ConVar g_BossProfileOverrideConVar;
ConVar g_PlayerBlinkRateConVar;
ConVar g_PlayerBlinkHoldTimeConVar;
ConVar g_SpecialRoundBehaviorConVar;
ConVar g_SpecialRoundForceConVar;
ConVar g_SpecialRoundOverrideConVar;
ConVar g_SpecialRoundIntervalConVar;
ConVar g_NewBossRoundBehaviorConVar;
ConVar g_NewBossRoundIntervalConVar;
ConVar g_NewBossRoundForceConVar;
ConVar g_IgnoreRoundWinConditionsConVar;
ConVar g_DisableBossCrushFixConVar;
ConVar g_EnableWallHaxConVar;
ConVar g_IgnoreRedPlayerDeathSwapConVar;
ConVar g_PlayerVoiceDistanceConVar;
ConVar g_PlayerVoiceWallScaleConVar;
ConVar g_UltravisionEnabledConVar;
ConVar g_UltravisionRadiusRedConVar;
ConVar g_UltravisionRadiusBlueConVar;
ConVar g_UltravisionBrightnessConVar;
ConVar g_NightvisionRadiusConVar;
ConVar g_NightvisionEnabledConVar;
ConVar g_GhostModeConnectionConVar;
ConVar g_GhostModeConnectionCheckConVar;
ConVar g_GhostModeConnectionToleranceConVar;
ConVar g_IntroEnabledConVar;
ConVar g_IntroDefaultHoldTimeConVar;
ConVar g_IntroDefaultFadeTimeConVar;
ConVar g_TimeLimitConVar;
ConVar g_TimeLimitEscapeConVar;
ConVar g_TimeGainFromPageGrabConVar;
ConVar g_WarmupRoundConVar;
ConVar g_WarmupRoundNumConVar;
ConVar g_PlayerViewbobHurtEnabledConVar;
ConVar g_PlayerViewbobSprintEnabledConVar;
ConVar g_PlayerProxyWaitTimeConVar;
ConVar g_PlayerProxyAskConVar;
ConVar g_PlayerAFKTimeConVar;
ConVar g_BlockSuicideDuringRoundConVar;
ConVar g_RaidMapConVar;
ConVar g_ProxyMapConVar;
ConVar g_BossChaseEndlesslyConVar;
ConVar g_SurvivalMapConVar;
ConVar g_BoxingMapConVar;
ConVar g_RenevantMapConVar;
ConVar g_DefaultRenevantBossConVar;
ConVar g_DefaultRenevantBossMessageConVar;
ConVar g_SlaughterRunMapConVar;
ConVar g_TimeEscapeSurvivalConVar;
ConVar g_SlaughterRunDivisibleTimeConVar;
ConVar g_UseAlternateConfigDirectoryConVar;
ConVar g_PlayerKeepWeaponsConVar;
ConVar g_FullyEnableSpectatorConVar;
ConVar g_AllowPlayerPeekingConVar;
ConVar g_UsePlayersForKillFeedConVar;
ConVar g_DefaultLegacyHudConVar;

ConVar g_RestartSessionConVar;
bool g_RestartSessionEnabled;

ConVar g_PlayerInfiniteSprintOverrideConVar;
ConVar g_PlayerInfiniteFlashlightOverrideConVar;
ConVar g_PlayerInfiniteBlinkOverrideConVar;

ConVar g_GravityConVar;
float g_Gravity;

ConVar g_MaxRoundsConVar;

bool g_20Dollars;

bool g_IsPlayerShakeEnabled;
bool g_bPlayerViewbobHurtEnabled;
bool g_bPlayerViewbobSprintEnabled;

Handle g_HudSync;
Handle g_HudSync2;
Handle g_HudSync3;
Handle g_RoundTimerSync;

Handle g_Cookie;

int g_SmokeSprite;
int g_LightningSprite;
int g_ShockwaveBeam;
int g_ShockwaveHalo;

// Global forwards.
GlobalForward g_OnBossAddedFwd;
GlobalForward g_OnBossSpawnFwd;
GlobalForward g_OnBossDespawnFwd;
GlobalForward g_OnBossChangeStateFwd;
GlobalForward g_OnBossAnimationUpdateFwd;
GlobalForward g_OnBossGetSpeedFwd;
GlobalForward g_OnBossGetWalkSpeedFwd;
GlobalForward g_OnBossSeeEntityFwd;
GlobalForward g_OnBossHearEntityFwd;
GlobalForward g_OnBossRemovedFwd;
GlobalForward g_OnBossStunnedFwd;
GlobalForward g_OnBossCloakedFwd;
GlobalForward g_OnBossDecloakedFwd;
GlobalForward g_OnPagesSpawnedFwd;
GlobalForward g_OnRoundStateChangeFwd;
GlobalForward g_OnClientCollectPageFwd;
GlobalForward g_OnClientBlinkFwd;
GlobalForward g_OnClientScareFwd;
GlobalForward g_OnClientCaughtByBossFwd;
GlobalForward g_OnClientGiveQueuePointsFwd;
GlobalForward g_OnClientActivateFlashlightFwd;
GlobalForward g_OnClientDeactivateFlashlightFwd;
GlobalForward g_OnClientBreakFlashlightFwd;
GlobalForward g_OnClientStartSprintingFwd;
GlobalForward g_OnClientStopSprintingFwd;
GlobalForward g_OnClientEscapeFwd;
GlobalForward g_OnClientLooksAtBossFwd;
GlobalForward g_OnClientLooksAwayFromBossFwd;
GlobalForward g_OnClientStartDeathCamFwd;
GlobalForward g_OnClientEndDeathCamFwd;
GlobalForward g_OnClientGetDefaultWalkSpeedFwd;
GlobalForward g_OnClientGetDefaultSprintSpeedFwd;
GlobalForward g_OnClientTakeDamageFwd;
GlobalForward g_OnClientSpawnedAsProxyFwd;
GlobalForward g_OnClientDamagedByBossFwd;
GlobalForward g_OnGroupGiveQueuePointsFwd;
GlobalForward g_OnRenevantTriggerWaveFwd;
GlobalForward g_OnBossPackVoteStartFwd;
GlobalForward g_OnDifficultyChangeFwd;

Handle g_hSDKGetMaxHealth;
Handle g_hSDKGetLastKnownArea;
Handle g_hSDKUpdateLastKnownArea;
DynamicHook g_hSDKWantsLagCompensationOnEntity;
DynamicHook g_hSDKShouldTransmit;
DynamicHook g_hSDKUpdateTransmitState;
DynamicHook g_hShouldCollide;
Handle g_hSDKGetLocomotionInterface;
Handle g_hSDKGetNextBot;
Handle g_hSDKEquipWearable;
Handle g_hSDKPlaySpecificSequence;
Handle g_hSDKPointIsWithin;
Handle g_hSDKPassesTriggerFilters;
Handle g_hSDKGetSmoothedVelocity;
Handle g_hSDKGetVectors;
Handle g_hSDKResetSequence;
Handle g_hSDKStartTouch;
Handle g_hSDKEndTouch;
Handle g_hSDKWeaponSwitch;
DynamicHook g_hSDKWeaponGetCustomDamageType;
DynamicHook g_hSDKProjectileCanCollideWithTeammates;

// SourceTV userid used for boss name
int g_SourceTVUserID = -1;
char g_sOldClientName[MAXPLAYERS + 1][64];
Handle g_TimerChangeClientName[MAXPLAYERS + 1] = null;

//Fail Timer
Handle g_TimerFail = null;

//Renevant
int g_RenevantWaveNumber = 0;
int g_RenevantFinaleTime = 0;
bool g_RenevantMultiEffect = false;
bool g_RenevantBeaconEffect = false;
bool g_Renevant90sEffect = false;
bool g_RenevantMarkForDeath = false;
bool g_IsRenevantMap = false;
Handle g_RenevantWaveTimer = null;
ArrayList g_RenevantWaveList;

stock ArrayList g_FuncNavPrefer;

#define SF2_PROJECTED_FLASHLIGHT_CONFIRM_SOUND "ui/item_acquired.wav"

#if defined DEBUG
#include "sf2/debug.sp"
#endif
#include "sf2/stocks.sp"
#include "sf2/logging.sp"
#include "sf2/profiles.sp"
//#include "sf2/nav.sp"
#include "sf2/effects.sp"
#include "sf2/playergroups.sp"
#include "sf2/mapentities.sp"
#include "sf2/menus.sp"
#include "sf2/tutorial.sp"
#include "sf2/npc.sp"
#include "sf2/pvp.sp"
#include "sf2/client.sp"
#include "sf2/specialround.sp"
#include "sf2/adminmenu.sp"
#include "sf2/traps.sp"
#include "sf2/extras/renevant_mode.sp"
#include "sf2/extras/natives.sp"
#include "sf2/extras/commands.sp"
#include "sf2/extras/game_events.sp"
#include "sf2/extras/afk_mode.sp"

SF2LogicRenevantEntity g_RenevantLogicEntity = view_as<SF2LogicRenevantEntity>(-1);

public void OnAllPluginsLoaded()
{
	SDK_Init();
}

public void OnPluginEnd()
{
	StopPlugin();
}
public void OnLibraryAdded(const char[] name)
{
	
	if (!strcmp(name, "SteamTools", false))
	{
		steamtools = true;
	}
	
	if (!strcmp(name, "SteamWorks", false))
	{
		steamworks = true;
	}
	
}
public void OnLibraryRemoved(const char[] name)
{
	
	if (!strcmp(name, "SteamTools", false))
	{
		steamtools = false;
	}
	
	if (!strcmp(name, "SteamWorks", false))
	{
		steamworks = false;
	}
	
}

public void OnMapStart()
{
	g_TimerFail = null;
	PvP_OnMapStart();
	FindHealthBar();
	PrecacheSound(SOUND_THUNDER, true);
	PrecacheSound("weapons/teleporter_send.wav");
	g_SmokeSprite = PrecacheModel("sprites/steam1.vmt");
	g_LightningSprite = PrecacheModel("sprites/lgtning.vmt");
	g_ShockwaveBeam = PrecacheModel("sprites/laser.vmt");
	g_ShockwaveHalo = PrecacheModel("sprites/halo01.vmt");
	PrecacheModel(LASER_MODEL, true);
	g_LaserIndex = PrecacheModel("materials/sprites/laser.vmt");
	char sOverlay[PLATFORM_MAX_PATH];
	g_CameraOverlayConVar.GetString(sOverlay, sizeof(sOverlay));
	PrecacheMaterial2(sOverlay);
	g_OverlayNoGrainConVar.GetString(sOverlay, sizeof(sOverlay));
	PrecacheMaterial2(sOverlay);
	g_GhostOverlayConVar.GetString(sOverlay, sizeof(sOverlay));
	PrecacheMaterial2(sOverlay);

	SF2MapEntity_OnMapStart();
}

public void OnConfigsExecuted()
{
	if (!g_EnabledConVar.BoolValue)
	{
		StopPlugin();
	}
	else
	{
		if (g_SlenderMapsOnlyConVar.BoolValue)
		{
			char sMap[256];
			GetCurrentMap(sMap, sizeof(sMap));
			
			if (!StrContains(sMap, "slender_", false) || !StrContains(sMap, "sf2_", false))
			{
				StartPlugin();
			}
			else
			{
				LogMessage("%s is not a Slender Fortress map. Plugin disabled!", sMap);
				StopPlugin();
			}
		}
		else
		{
			StartPlugin();
		}
	}
}

static void StartPlugin()
{
	if (g_Enabled) return;
	
	g_Enabled = true;
	
	InitializeLogging();
	
	#if defined DEBUG
	InitializeDebugLogging();
	#endif
	
	int i2 = 0;
	
	// Handle ConVars.
	ConVar hCvar = FindConVar("mp_friendlyfire");
	if (hCvar != null) hCvar.SetBool(true);
	
	hCvar = FindConVar("mp_flashlight");
	if (hCvar != null) hCvar.SetBool(true);
	
	hCvar = FindConVar("mat_supportflashlight");
	if (hCvar != null) hCvar.SetBool(true);
	
	hCvar = FindConVar("mp_autoteambalance");
	if (hCvar != null) hCvar.SetBool(false);

	hCvar = FindConVar("mp_scrambleteams_auto");
	if (hCvar != null) hCvar.SetBool(false);

	if (!g_FullyEnableSpectatorConVar.BoolValue)
	{
		hCvar = FindConVar("mp_allowspectators");
		if (hCvar != null) hCvar.SetBool(false);
	}
	
	g_Gravity = g_GravityConVar.FloatValue;
	
	g_20Dollars = g_20DollarsConVar.BoolValue;
	
	g_IsPlayerShakeEnabled = g_PlayerShakeEnabledConVar.BoolValue;
	g_bPlayerViewbobHurtEnabled = g_PlayerViewbobHurtEnabledConVar.BoolValue;
	g_bPlayerViewbobSprintEnabled = g_PlayerViewbobSprintEnabledConVar.BoolValue;
	
	#if defined _SteamWorks_Included
	if (steamworks)
	{
		SteamWorks_SetGameDescription("Slender Fortress ("...PLUGIN_VERSION_DISPLAY...")");
		steamtools = false;
	}
	#endif
	#if defined _steamtools_included
	if (steamtools)
	{
		Steam_SetGameDescription("Slender Fortress ("...PLUGIN_VERSION_DISPLAY...")");
		steamworks = false;
	}
	#endif
	
	if (steamworks) i2 = 1;
	else if (steamtools) i2 = 2;
	
	PrecacheStuff();
	
	if (i2 == 1 || i2 == 2 || i2 == 0) WarningRemoval(); //Sourcemod loves to call steamworks and steamtools unused symbols, do this to prevent this
	
	// Reset special round.
	g_IsSpecialRound = false;
	g_IsSpecialRoundNew = false;
	g_IsSpecialRoundContinuous = false;
	g_iSpecialRoundCount = 1;
	SF_RemoveAllSpecialRound();
	
	SpecialRoundReset();
	
	// Reset boss rounds.
	g_bNewBossRound = false;
	g_bNewBossRoundNew = false;
	g_bNewBossRoundContinuous = false;
	g_iNewBossRoundCount = 1;
	g_strNewBossRoundProfile[0] = '\0';
	
	// Reset global round vars.
	g_iRoundCount = 0;
	g_iRoundEndCount = 0;
	g_iRoundActiveCount = 0;
	g_iRoundState = SF2RoundState_Invalid;
	g_hRoundMessagesTimer = CreateTimer(200.0, Timer_RoundMessages, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundMessagesNum = 0;
	
	g_iRoundWarmupRoundCount = 0;
	
	g_ClientAverageUpdateTimer = CreateTimer(0.1, Timer_ClientAverageUpdate, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	g_hBossCountUpdateTimer = CreateTimer(2.0, Timer_BossCountUpdate, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	g_OnGameFrameTimer = CreateTimer(0.1, Timer_GlobalGameFrame, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	SetRoundState(SF2RoundState_Waiting);
	
	ReloadBossProfiles();
	ReloadRestrictedWeapons();
	ReloadSpecialRounds();
	
	NPCOnConfigsExecuted();
	
	InitializeBossPackVotes();
	SetupTimeLimitTimerForBossPackVote();
	
	// Late load compensation.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		OnClientPutInServer(i);
	}
}

void WarningRemoval()
{
	
}

static void PrecacheStuff()
{
	// Initialize particles.
	g_Particles[CriticalHit] = PrecacheParticleSystem(CRIT_PARTICLENAME);
	g_Particles[MiniCritHit] = PrecacheParticleSystem(MINICRIT_PARTICLENAME);
	g_Particles[ZapParticle] = PrecacheParticleSystem(ZAP_PARTICLENAME);
	g_Particles[FireworksRED] = PrecacheParticleSystem(FIREWORKSRED_PARTICLENAME);
	g_Particles[FireworksBLU] = PrecacheParticleSystem(FIREWORKSBLU_PARTICLENAME);
	g_Particles[TeleportedInBlu] = PrecacheParticleSystem(TELEPORTEDINBLU_PARTICLENAME);
	
	for (int i = 0; i < sizeof(g_strSoundNightmareMode) - 1; i++) PrecacheSound2(g_strSoundNightmareMode[i]);
	
	PrecacheSound("ui/itemcrate_smash_ultrarare_short.wav");
	PrecacheSound(")weapons/crusaders_crossbow_shoot.wav");
	PrecacheSound(MINICRIT_SOUND);
	PrecacheSound(CRIT_SOUND);
	PrecacheSound(ZAP_SOUND);
	PrecacheSound(PAGE_DETECTOR_BEEP);
	PrecacheSound(EXPLOSIVEDANCE_EXPLOSION1);
	PrecacheSound(EXPLOSIVEDANCE_EXPLOSION2);
	PrecacheSound(EXPLOSIVEDANCE_EXPLOSION3);
	PrecacheSound(SPECIAL1UPSOUND);
	PrecacheSound("player/spy_shield_break.wav");
	
	PrecacheSound(CRIT_ROLL);
	PrecacheSound(EXPLODE_PLAYER);
	PrecacheSound(UBER_ROLL);
	PrecacheSound(NO_EFFECT_ROLL);
	PrecacheSound(BLEED_ROLL);
	PrecacheSound(GENERIC_ROLL_TICK_1);
	PrecacheSound(GENERIC_ROLL_TICK_2);
	PrecacheSound(LOSE_SPRINT_ROLL);
	PrecacheSound(FIREWORK_EXPLOSION);
	PrecacheSound(FIREWORK_START);
	PrecacheSound(MINICRIT_BUFF);
	PrecacheSound(NULLSOUND);
	PrecacheSound(JARATE_ROLL);
	PrecacheSound(GAS_ROLL);
	
	// simple_bot;
	PrecacheModel("models/humans/group01/female_01.mdl", true);
	
	PrecacheModel(PAGE_MODEL, true);
	PrecacheModel(SF_KEYMODEL, true);
	PrecacheModel(TRAP_MODEL, true);
	
	PrecacheSound2(FLASHLIGHT_CLICKSOUND);
	PrecacheSound2(FLASHLIGHT_CLICKSOUND_NIGHTVISION);
	PrecacheSound2(FLASHLIGHT_BREAKSOUND);
	PrecacheSound2(FLASHLIGHT_NOSOUND);
	PrecacheSound2(PAGE_GRABSOUND);
	PrecacheSound2(TWENTYDOLLARS_MUSIC);

	PrecacheSound(DEFAULT_CLOAKONSOUND);
	PrecacheSound(DEFAULT_CLOAKOFFSOUND);
	
	PrecacheSound(FIREBALL_IMPACT);
	PrecacheSound(FIREBALL_SHOOT);
	PrecacheSound(ICEBALL_IMPACT);
	PrecacheSound(ROCKET_SHOOT);
	PrecacheSound(ROCKET_IMPACT);
	PrecacheSound(GRENADE_SHOOT);
	PrecacheSound(SENTRYROCKET_SHOOT);
	PrecacheSound(ARROW_SHOOT);
	PrecacheSound(MANGLER_EXPLODE1);
	PrecacheSound(MANGLER_EXPLODE2);
	PrecacheSound(MANGLER_EXPLODE3);
	PrecacheSound(MANGLER_SHOOT);
	PrecacheSound(BASEBALL_SHOOT);
	
	PrecacheSound(THANATOPHOBIA_MEDICNO);
	
	PrecacheModel(ROCKET_MODEL, true);
	PrecacheModel(GRENADE_MODEL, true);
	PrecacheModel(BASEBALL_MODEL, true);
	
	PrecacheSound(JARATE_HITPLAYER);
	PrecacheSound(STUN_HITPLAYER);
	
	PrecacheSound2(MUSIC_GOTPAGES1_SOUND);
	PrecacheSound2(MUSIC_GOTPAGES2_SOUND);
	PrecacheSound2(MUSIC_GOTPAGES3_SOUND);
	PrecacheSound2(MUSIC_GOTPAGES4_SOUND);
	
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_1);
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_2);
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_3);
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_4);
	PrecacheSound2(HYPERSNATCHER_NIGHTAMRE_5);
	PrecacheSound2(SNATCHER_APOLLYON_1);
	PrecacheSound2(SNATCHER_APOLLYON_2);
	PrecacheSound2(SNATCHER_APOLLYON_3);
	
	PrecacheSound2(NINETYSMUSIC);
	PrecacheSound2(TRIPLEBOSSESMUSIC);
	
	PrecacheSound2(TRAP_CLOSE);
	PrecacheSound2(TRAP_DEPLOY);
	
	for (int i = 0; i < sizeof(g_sPageCollectDuckSounds); i++)
	{
		PrecacheSound(g_sPageCollectDuckSounds[i]);
	}
	
	PrecacheSound2(PROXY_RAGE_MODE_SOUND);
	
	PrecacheSound2(SF2_PROJECTED_FLASHLIGHT_CONFIRM_SOUND);
	
	for (int i = 0; i < sizeof(g_strPlayerBreathSounds); i++)
	{
		PrecacheSound2(g_strPlayerBreathSounds[i]);
	}
	
	// Special round.
	PrecacheSound2(SR_MUSIC);
	PrecacheSound2(SR_SOUND_SELECT);
	PrecacheSound(SR_SOUND_SELECT_BR);
	PrecacheSound2(SF2_INTRO_DEFAULT_MUSIC);
	
	PrecacheMaterial2(SF2_OVERLAY_MARBLEHORNETS);
	
	AddFileToDownloadsTable("models/slender/pickups/sheet.mdl");
	AddFileToDownloadsTable("models/slender/pickups/sheet.dx80.vtx");
	AddFileToDownloadsTable("models/slender/pickups/sheet.dx90.vtx");
	AddFileToDownloadsTable("models/slender/pickups/sheet.phy");
	AddFileToDownloadsTable("models/slender/pickups/sheet.sw.vtx");
	AddFileToDownloadsTable("models/slender/pickups/sheet.vvd");
	AddFileToDownloadsTable("models/slender/pickups/sheet.xbox");
	
	AddFileToDownloadsTable("models/demani_sf/key_australium.mdl");
	AddFileToDownloadsTable("models/demani_sf/key_australium.dx80.vtx");
	AddFileToDownloadsTable("models/demani_sf/key_australium.dx90.vtx");
	AddFileToDownloadsTable("models/demani_sf/key_australium.sw.vtx");
	AddFileToDownloadsTable("models/demani_sf/key_australium.vvd");
	
	AddFileToDownloadsTable("materials/models/demani_sf/key_australium.vmt");
	AddFileToDownloadsTable("materials/models/demani_sf/key_australium.vtf");
	AddFileToDownloadsTable("materials/models/demani_sf/key_australium_normal.vtf");
	
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_1.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_1.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_2.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_2.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_3.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_3.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_4.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_4.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_5.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_5.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_6.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_6.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_7.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_7.vmt");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_8.vtf");
	AddFileToDownloadsTable("materials/models/jason278/slender/sheets/sheet_8.vmt");
	
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.mdl");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.sw.vtx");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.dx80.vtx");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.dx90.vtx");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.phy");
	AddFileToDownloadsTable("models/mentrillum/traps/beartrap.vvd");
	
	AddFileToDownloadsTable("materials/models/mentrillum/traps/beartrap/trap_m.vtf");
	AddFileToDownloadsTable("materials/models/mentrillum/traps/beartrap/trap_m.vmt");
	AddFileToDownloadsTable("materials/models/mentrillum/traps/beartrap/trap_n.vtf");
	AddFileToDownloadsTable("materials/models/mentrillum/traps/beartrap/trap_r.vtf");
	
	// pvp
	PvP_Precache();
}

static void StopPlugin()
{
	if (!g_Enabled) return;
	
	g_Enabled = false;
	
	g_RestartSessionEnabled = false;
	g_RestartSessionConVar.SetBool(false);

	// Reset CVars.
	ConVar hCvar = FindConVar("mp_friendlyfire");
	if (hCvar != null) hCvar.SetBool(false);
	
	hCvar = FindConVar("mp_flashlight");
	if (hCvar != null) hCvar.SetBool(false);
	
	hCvar = FindConVar("mat_supportflashlight");
	if (hCvar != null) hCvar.SetBool(false);
	
	if (MusicActive()) NPCStopMusic();
	
	//Remove Timer handles
	CleanTimerHandles();
	
	// Cleanup bosses.
	NPCRemoveAll();
	
	// Cleanup clients.
	for (int i = 1; i <= MaxClients; i++)
	{
		ClientResetFlashlight(i);
		ClientDeactivateUltravision(i);
		ClientDisableConstantGlow(i);
		ClientRemoveInteractiveGlow(i);
		g_TimerChangeClientName[i] = null;
	}

	for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
	{
		if (g_BossPathFollower[bossIndex])
		{
			g_BossPathFollower[bossIndex].Destroy();
			g_BossPathFollower[bossIndex] = view_as<PathFollower>(0);
		}
	}

	g_RenevantMultiEffect = false;
	g_RenevantBeaconEffect = false;
	g_Renevant90sEffect = false;
	g_RenevantMarkForDeath = false;
	
	BossProfilesOnMapEnd();
	
	Tutorial_OnMapEnd();

	if (g_FuncNavPrefer != null) delete g_FuncNavPrefer;
	
	delete g_Config;
}

public void CleanTimerHandles()
{
	g_hRoundMessagesTimer = null;
	g_ClientAverageUpdateTimer = null;
	g_hBossCountUpdateTimer = null;
	g_hBlueNightvisionOutlineTimer = null;
	g_hRoundIntroTextTimer = null;
	g_hRoundIntroTimer = null;
	g_hRoundGraceTimer = null;
	g_hRoundTimer = null;
	g_RenevantWaveTimer = null;
	g_hVoteTimer = null;
	g_TimerFail = null;
	g_BossPackVoteTimer = null;
	g_BossPackVoteMapTimer = null;
	timerMusic = null;
	g_OnGameFrameTimer = null;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsClientInGame(i)) continue;
		g_hPlayerPageRewardTimer[i] = null;
		g_hPlayerPageRewardCycleTimer[i] = null;
		g_hPlayerOverlayCheck[i] = null;
		g_hPlayerPostWeaponsTimer[i] = null;
		g_hPlayerSwitchBlueTimer[i] = null;
		g_PlayerIntroMusicTimer[i] = null;
		g_PlayerPvPRespawnTimer[i] = null;
		g_PlayerPvPTimer[i] = null;
		g_PlayerIgniteTimer[i] = null;
		g_PlayerResetIgnite[i] = null;
		g_PlayerStaticTimer[i] = null;
		g_hPlayerLastStaticTimer[i] = null;
		g_ClientSpecialRoundTimer[i] = null;
		g_PlayerBreathTimer[i] = null;
		g_PlayerSprintTimer[i] = null;
		g_hPlayerProxyAvailableTimer[i] = null;
		g_PlayerProxyControlTimer[i] = null;
		g_ClientGlowTimer[i] = null;
		g_PlayerDeathCamTimer[i] = null;
		g_PlayerGhostModeConnectionCheckTimer[i] = null;
		g_PlayerCampingTimer[i] = null;
		g_PlayerBlinkTimer[i] = null;
		g_PlayerMusicTimer[i] = null;
		g_Player90sMusicTimer[i] = null;
		g_PlayerFlashlightBatteryTimer[i] = null;
	}
	for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
	{
		if (NPCGetUniqueID(bossIndex) == -1) continue;
		g_BossFailSafeTimer[bossIndex] = null;
		g_SlenderRage1Timer[bossIndex] = null;
		g_SlenderRage2Timer[bossIndex] = null;
		g_SlenderRage3Timer[bossIndex] = null;
		g_SlenderHealTimer[bossIndex] = null;
		g_SlenderHealDelayTimer[bossIndex] = null;
		g_SlenderStartFleeTimer[bossIndex] = null;
		g_SlenderAttackTimer[bossIndex] = null;
		g_NpcLifeStealTimer[bossIndex] = null;
		g_SlenderChaseInitialTimer[bossIndex] = null;
		g_SlenderEntityThink[bossIndex] = null;
		g_SlenderHealEventTimer[bossIndex] = null;
		g_SlenderLaserTimer[bossIndex] = null;
		g_SlenderThink[bossIndex] = null;
		g_SlenderSpawnTimer[bossIndex] = null;
		g_SlenderBurnTimer[bossIndex] = null;
		g_SlenderBleedTimer[bossIndex] = null;
		g_SlenderMarkedTimer[bossIndex] = null;
		g_SlenderFakeTimer[bossIndex] = null;
		g_SlenderDeathCamTimer[bossIndex] = null;
	}
}

public void OnMapEnd()
{
	StopPlugin();
}

public void OnMapTimeLeftChanged()
{
	if (g_Enabled)
	{
		SetupTimeLimitTimerForBossPackVote();
	}
}

public void TF2_OnConditionAdded(int client, TFCond cond)
{
	if (cond == TFCond_Taunting)
	{
		if (IsClientInGhostMode(client))
		{
			// Stop ghosties from taunting.
			TF2_RemoveCondition(client, TFCond_Taunting);
		}
		
		if (g_PlayerProxy[client])
		{
			g_PlayerProxyControl[client] -= 20;
			if (g_PlayerProxyControl[client] <= 0) g_PlayerProxyControl[client] = 0;
		}
	}
	if (cond == view_as<TFCond>(82))
	{
		if (g_PlayerProxy[client])
		{
			//Stop proxies from using kart commands
			TF2_RemoveCondition(client, TFCond_HalloweenKart);
			TF2_RemoveCondition(client, TFCond_HalloweenKartDash);
			TF2_RemoveCondition(client, TFCond_HalloweenKartNoTurn);
			TF2_RemoveCondition(client, TFCond_HalloweenKartCage);
			TF2_RemoveCondition(client, TFCond_SpawnOutline);
		}
	}
}

public Action Timer_GlobalGameFrame(Handle timer)
{
	if (!g_Enabled) return Plugin_Stop;
	
	if (timer != g_OnGameFrameTimer) return Plugin_Stop;
	
	if (IsRoundPlaying()) g_RoundTimeMessage += 0.1;
	else g_RoundTimeMessage = 0.0;

	if (SF_IsBoxingMap() && IsRoundInEscapeObjective())
	{
		char sBoxingBossName[SF2_MAX_NAME_LENGTH], sMessage[1024];
		for (int i = 0; i < MAX_BOSSES; i++)
		{
			if (NPCGetUniqueID(i) == -1) continue;
			NPCGetBossName(i, sBoxingBossName, sizeof(sBoxingBossName));
			int stunHealth = RoundToNearest(NPCChaserGetStunHealth(i));
			if (stunHealth < 0 || NPCGetEntRef(i) == INVALID_ENT_REFERENCE) stunHealth = 0;
			int stunInitHealth = RoundToNearest(NPCChaserGetStunInitialHealth(i));
			Format(sMessage, sizeof(sMessage), "%s\n%s's current health is %i of %i", sMessage, sBoxingBossName, stunHealth, stunInitHealth);
		}
		for (int client = 1; client < MaxClients; client++)
		{
			if (!IsClientInGame(client) || IsFakeClient(client) || !IsPlayerAlive(client) || (g_PlayerEliminated[client] && !IsClientInGhostMode(client)) || DidClientEscape(client)) continue;

			PrintCenterText(client, sMessage);
		}
	}

	// Process through boss movement.
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1) continue;
		
		int iBoss = NPCGetEntIndex(i);
		if (!iBoss || iBoss == INVALID_ENT_REFERENCE) continue;
		
		if (NPCGetFlags(i) & SFF_MARKEDASFAKE) continue;
		
		int iType = NPCGetType(i);
		
		switch (iType)
		{
			case SF2BossType_Static:
			{
				float myPos[3], hisPos[3];
				SlenderGetAbsOrigin(i, myPos);
				AddVectors(myPos, g_SlenderEyePosOffset[i], myPos);
				
				int iBestPlayer = -1;
				float flBestDistance = SquareFloat(16384.0);
				float flTempDistance;
				
				for (int client = 1; client <= MaxClients; client++)
				{
					if (!IsClientInGame(client) || !IsPlayerAlive(client) || IsClientInGhostMode(client) || IsClientInDeathCam(client)) continue;
					if (!IsPointVisibleToPlayer(client, myPos, false, false)) continue;
					
					GetClientAbsOrigin(client, hisPos);
					
					flTempDistance = GetVectorSquareMagnitude(myPos, hisPos);
					if (flTempDistance < flBestDistance)
					{
						iBestPlayer = client;
						flBestDistance = flTempDistance;
					}
				}
				
				if (iBestPlayer > 0)
				{
					SlenderGetAbsOrigin(i, myPos);
					GetClientAbsOrigin(iBestPlayer, hisPos);
					
					if (!SlenderOnlyLooksIfNotSeen(i) || !IsPointVisibleToAPlayer(myPos, false, SlenderUsesBlink(i)))
					{
						float flTurnRate = NPCGetTurnRate(i);
						
						if (flTurnRate > 0.0)
						{
							float flMyEyeAng[3], ang[3];
							GetEntPropVector(iBoss, Prop_Data, "m_angAbsRotation", flMyEyeAng);
							AddVectors(flMyEyeAng, g_SlenderEyeAngOffset[i], flMyEyeAng);
							SubtractVectors(hisPos, myPos, ang);
							GetVectorAngles(ang, ang);
							ang[0] = 0.0;
							ang[1] += (AngleDiff(ang[1], flMyEyeAng[1]) >= 0.0 ? 1.0 : -1.0) * flTurnRate * GetTickInterval();
							ang[2] = 0.0;
							
							// Take care of angle offsets.
							AddVectors(ang, g_SlenderEyePosOffset[i], ang);
							for (int i2 = 0; i2 < 3; i2++) ang[i2] = AngleNormalize(ang[i2]);
							
							TeleportEntity(iBoss, NULL_VECTOR, ang, NULL_VECTOR);
						}
					}
				}
			}
		}
	}
	// Check if we can add some proxies.
	if (IsRoundPlaying() && !SF_IsRenevantMap() && !SF_IsSlaughterRunMap())
	{
			ArrayList hProxyCandidates = new ArrayList();

			for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
			{
				if (NPCGetUniqueID(bossIndex) == -1) continue;
				
				if (!(NPCGetFlags(bossIndex) & SFF_PROXIES)) continue;
				
				if (g_SlenderCopyMaster[bossIndex] != -1) continue; // Copies cannot generate proxies.
				
				if (GetGameTime() < g_SlenderTimeUntilNextProxy[bossIndex]) continue; // Proxy spawning hasn't cooled down yet.

				int iTeleportTarget = EntRefToEntIndex(g_SlenderProxyTarget[bossIndex]);
				if (!iTeleportTarget || iTeleportTarget == INVALID_ENT_REFERENCE) continue; // No teleport target.

				int difficulty = GetLocalGlobalDifficulty(bossIndex);

				int iMaxProxies = g_SlenderMaxProxies[bossIndex][difficulty];
				if (g_InProxySurvivalRageMode) iMaxProxies += 5;
				
				int iNumActiveProxies = 0;
				
				for (int client = 1; client <= MaxClients; client++)
				{
					if (!IsClientInGame(client) || !g_PlayerEliminated[client]) continue;
					if (!g_PlayerProxy[client]) continue;
					
					if (NPCGetFromUniqueID(g_PlayerProxyMaster[client]) == bossIndex)
					{
						iNumActiveProxies++;
					}
				}
				if (iNumActiveProxies >= iMaxProxies) 
				{
#if defined DEBUG
					SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d has too many active proxies!", bossIndex);
					//PrintToChatAll("[PROXIES] Boss %d has too many active proxies!", bossIndex);
#endif
					continue;
				}
				
				float flSpawnChanceMin = NPCGetProxySpawnChanceMin(bossIndex, difficulty);
				float flSpawnChanceMax = NPCGetProxySpawnChanceMax(bossIndex, difficulty);
				float flSpawnChanceThreshold = NPCGetProxySpawnChanceThreshold(bossIndex, difficulty) * NPCGetAnger(bossIndex);
				
				float flChance = GetRandomFloat(flSpawnChanceMin, flSpawnChanceMax);
				if (flChance > flSpawnChanceThreshold && !g_InProxySurvivalRageMode) 
				{
#if defined DEBUG
					SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d's chances weren't in his favor!", bossIndex);
					//PrintToChatAll("[PROXIES] Boss %d's chances weren't in his favor!", bossIndex);
#endif
					continue;
				}
				
				int iAvailableProxies = iMaxProxies - iNumActiveProxies;
				
				int iSpawnNumMin = NPCGetProxySpawnNumMin(bossIndex, difficulty);
				int iSpawnNumMax = NPCGetProxySpawnNumMax(bossIndex, difficulty);
				
				int iSpawnNum = 0;
				
				// Get a list of people we can transform into a good Proxy.
				hProxyCandidates.Clear();
				
				for (int client = 1; client <= MaxClients; client++)
				{
					if (!IsClientInGame(client) || !g_PlayerEliminated[client] || GetClientTeam(client) == TFTeam_Red) continue;
					if (g_PlayerProxy[client]) continue;
					
					if (!g_PlayerPreferences[client].PlayerPreference_EnableProxySelection)
					{
#if defined DEBUG
						SendDebugMessageToPlayer(client, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because of your preferences.", bossIndex);
						//PrintToChatAll("[PROXIES] You were rejected for being a proxy for boss %d because of your preferences.", bossIndex);
#endif
						continue;
					}
					
					if (!g_bPlayerProxyAvailable[client])
					{
#if defined DEBUG
						SendDebugMessageToPlayer(client, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because of your cooldown.", bossIndex);
#endif
						continue;
					}
					
					if (g_bPlayerProxyAvailableInForce[client])
					{
#if defined DEBUG
						SendDebugMessageToPlayer(client, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because you're already being forced into a Proxy.", bossIndex);
#endif
						continue;
					}
					
					if (!IsClientParticipating(client))
					{
#if defined DEBUG
						SendDebugMessageToPlayer(client, DEBUG_BOSS_PROXIES, 0, "[PROXIES] You were rejected for being a proxy for boss %d because you're not participating.", bossIndex);
#endif
						continue;
					}
					
					hProxyCandidates.Push(client);
					iSpawnNum++;
				}
				
				if (iSpawnNum >= iSpawnNumMax)
				{
					iSpawnNum = GetRandomInt(iSpawnNumMin, iSpawnNumMax);
				}
				else if (iSpawnNum >= iSpawnNumMin)
				{
					iSpawnNum = GetRandomInt(iSpawnNumMin, iSpawnNum);
				}
				
				if (iSpawnNum <= 0) 
				{
#if defined DEBUG
					SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d had a set spawn number of 0!", bossIndex);
#endif
					continue;
				}
				bool bCooldown = false;
				// Randomize the array.
				SortADTArray(hProxyCandidates, Sort_Random, Sort_Integer);
				
				float flDestinationPos[3];
				
				for (int iNum = 0; iNum < iSpawnNum && iNum < iAvailableProxies; iNum++)
				{
					int client = hProxyCandidates.Get(iNum);
					int iSpawnPoint = -1;

					if (!SpawnProxy(client, bossIndex, flDestinationPos, iSpawnPoint))
					{
#if defined DEBUG
						SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0, "[PROXIES] Boss %d could not find any areas to place proxies (spawned %d)!", bossIndex, iNum);
						//PrintToChatAll("[PROXIES] Boss %d could not find any areas to place proxies (spawned %d)!", bossIndex, iNum);
#endif
						break;
					}
					bCooldown = true;
					if (!g_PlayerPreferences[client].PlayerPreference_ProxyShowMessage)
					{
						ClientStartProxyForce(client, NPCGetUniqueID(bossIndex), flDestinationPos, iSpawnPoint);
					}
					else
					{
						if (!IsRoundEnding() && !IsRoundInWarmup() && !IsRoundInIntro()) DisplayProxyAskMenu(client, NPCGetUniqueID(bossIndex), flDestinationPos, iSpawnPoint);
					}
				}
				// Set the cooldown time!
				if (bCooldown)
				{
					float flSpawnCooldownMin = NPCGetProxySpawnCooldownMin(bossIndex, difficulty);
					float flSpawnCooldownMax = NPCGetProxySpawnCooldownMax(bossIndex, difficulty);
				
					g_SlenderTimeUntilNextProxy[bossIndex] = GetGameTime() + GetRandomFloat(flSpawnCooldownMin, flSpawnCooldownMax);
				}
				else
					g_SlenderTimeUntilNextProxy[bossIndex] = GetGameTime() + GetRandomFloat(3.0, 4.0);
				
#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_BOSS_PROXIES, 0,"[PROXIES] Boss %d finished proxy process!", bossIndex);
#endif
			}
			
			delete hProxyCandidates;
	}
	
	PvP_OnGameFrame();
	
	return Plugin_Continue;
}

public Action Hook_CommandBuild(int client, const char[] command, int argc)
{
	if (!g_Enabled) return Plugin_Continue;
	if (!IsClientInPvP(client)) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action Hook_CommandTaunt(int client, const char[] command, int argc)
{
	if (!g_Enabled) return Plugin_Continue;
	if (!g_PlayerEliminated[client] && GetRoundState() == SF2RoundState_Intro) return Plugin_Handled;
	if (!g_PlayerEliminated[client] && ClientStartPeeking(client)) return Plugin_Handled;
	if (IsClientInGhostMode(client)) return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action Hook_CommandDisguise(int client, const char[] command, int argc)
{
	if (!g_Enabled) return Plugin_Continue;
	return Plugin_Handled;
}

public Action Timer_BlueNightvisionOutline(Handle timer)
{
	if (timer != g_hBlueNightvisionOutlineTimer) return Plugin_Stop;
	
	if (!g_Enabled) return Plugin_Stop;
	
	for (int npcIndex = 0; npcIndex < MAX_BOSSES; npcIndex++)
	{
		if (NPCGetUniqueID(npcIndex) == -1) continue;
		SlenderRemoveGlow(npcIndex);
		if (NPCGetCustomOutlinesState(npcIndex))
		{
			if (!NPCGetRainbowOutlineState(npcIndex))
			{
				int color[4];
				color[0] = NPCGetOutlineColorR(npcIndex);
				color[1] = NPCGetOutlineColorG(npcIndex);
				color[2] = NPCGetOutlineColorB(npcIndex);
				color[3] = NPCGetOutlineTransparency(npcIndex);
				if (color[0] < 0) color[0] = 0;
				if (color[1] < 0) color[1] = 0;
				if (color[2] < 0) color[2] = 0;
				if (color[3] < 0) color[3] = 0;
				if (color[0] > 255) color[0] = 255;
				if (color[1] > 255) color[1] = 255;
				if (color[2] > 255) color[2] = 255;
				if (color[3] > 255) color[3] = 255;
				SlenderAddGlow(npcIndex, _, color);
			}
			else SlenderAddGlow(npcIndex, _, view_as<int>( { 0, 0, 0, 0 } ));
		}
		else
		{
			int iPurple[4] = { 150, 0, 255, 255 };
			SlenderAddGlow(npcIndex, _, iPurple);
		}
	}
	return Plugin_Continue;
}

public Action Timer_BossCountUpdate(Handle timer)
{
	if (timer != g_hBossCountUpdateTimer) return Plugin_Stop;
	
	if (!g_Enabled) return Plugin_Stop;
	
	int iBossCount = NPCGetCount();
	int iBossPreferredCount;
	
	for (int i = 0; i < MAX_BOSSES; i++)
	{
		if (NPCGetUniqueID(i) == -1 || 
			g_SlenderCopyMaster[i] != -1 || 
			(NPCGetFlags(i) & SFF_FAKE))
		{
			continue;
		}
		
		iBossPreferredCount++;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || 
			!IsPlayerAlive(i) || 
			g_PlayerEliminated[i] || 
			IsClientInGhostMode(i) || 
			IsClientInDeathCam(i) || 
			DidClientEscape(i)) continue;
		
		// Check if we're near any bosses.
		int iClosest = -1;
		float flBestDist = SquareFloat(SF2_BOSS_PAGE_CALCULATION);
		
		for (int iBoss = 0; iBoss < MAX_BOSSES; iBoss++)
		{
			if (NPCGetUniqueID(iBoss) == -1) continue;
			if (NPCGetEntIndex(iBoss) == INVALID_ENT_REFERENCE) continue;
			if (NPCGetFlags(iBoss) & SFF_FAKE) continue;
			
			float flDist = NPCGetDistanceFromEntity(iBoss, i);
			if (flDist < flBestDist)
			{
				iClosest = iBoss;
				flBestDist = flDist;
				break;
			}
		}
		
		if (iClosest != -1) continue;
		
		iClosest = -1;
		flBestDist = SquareFloat(SF2_BOSS_PAGE_CALCULATION);
		
		for (int client = 1; client <= MaxClients; client++)
		{
			if (!IsValidClient(client) || 
				!IsPlayerAlive(client) || 
				g_PlayerEliminated[client] || 
				IsClientInGhostMode(client) || 
				IsClientInDeathCam(client) || 
				DidClientEscape(client))
			{
				continue;
			}
			
			bool bwub = false;
			for (int iBoss = 0; iBoss < MAX_BOSSES; iBoss++)
			{
				if (NPCGetUniqueID(iBoss) == -1) continue;
				if (NPCGetFlags(iBoss) & SFF_FAKE) continue;
				
				if (g_SlenderTarget[iBoss] == client)
				{
					bwub = true;
					break;
				}
			}
			
			if (!bwub) continue;
			
			float flDist = EntityDistanceFromEntity(i, client);
			if (flDist < flBestDist)
			{
				iClosest = client;
				flBestDist = flDist;
			}
		}
		
		if (!IsValidClient(iClosest))
		{
			// No one's close to this dude? DUDE! WE NEED ANOTHER BOSS!
			iBossPreferredCount++;
		}
	}
	
	int iDiff = iBossCount - iBossPreferredCount;
	if (iDiff)
	{
		if (iDiff > 0)
		{
			int iCount = iDiff;
			// We need less bosses. Try and see if we can remove some.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (g_SlenderCopyMaster[i] == -1) continue;
				if (PeopleCanSeeSlender(i, _, false)) continue;
				if (NPCGetFlags(i) & SFF_FAKE) continue;
				
				if (SlenderCanRemove(i))
				{
					NPCRemove(i);
					iCount--;
				}
				
				if (iCount <= 0)
				{
					break;
				}
			}
		}
		else
		{
			char profile[SF2_MAX_PROFILE_NAME_LENGTH];
			
			int iCount = RoundToFloor(FloatAbs(float(iDiff)));
			// Add int bosses (copy of the first boss).
			for (int i = 0; i < MAX_BOSSES && iCount > 0; i++)
			{
				SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(i);
				if (!Npc.IsValid()) continue;
				if (g_SlenderCopyMaster[Npc.Index] != -1) continue;
				if (!(Npc.Flags & SFF_COPIES)) continue;
				if (Npc.Flags & SFF_FAKE) continue;
				
				// Get the number of copies I already have and see if I can have more copies.
				int copyCount;
				for (int i2 = 0; i2 < MAX_BOSSES; i2++)
				{
					if (NPCGetUniqueID(i2) == -1) continue;
					if (g_SlenderCopyMaster[i2] != i) continue;
					
					copyCount++;
				}

				int difficulty = GetLocalGlobalDifficulty(Npc.Index);
				
				Npc.GetProfile(profile, sizeof(profile));
				int copyDifficulty = g_SlenderMaxCopies[Npc.Index][difficulty];
				if (copyCount >= copyDifficulty)
				{
					continue;
				}
				SF2NPC_BaseNPC NpcCopy = AddProfile(profile, _, Npc);
				if (!NpcCopy.IsValid())
				{
					//LogError("Could not add copy for %d: No free slots!", i);
				}
				
				iCount--;
			}
		}
	}
	return Plugin_Continue;
}

void ReloadRestrictedWeapons()
{
	if (g_RestrictedWeaponsConfig != null)
	{
		delete g_RestrictedWeaponsConfig;
		g_RestrictedWeaponsConfig = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if (!g_UseAlternateConfigDirectoryConVar.BoolValue) BuildPath(Path_SM, buffer, sizeof(buffer), FILE_RESTRICTEDWEAPONS);
	else BuildPath(Path_SM, buffer, sizeof(buffer), FILE_RESTRICTEDWEAPONS_DATA);
	KeyValues kv = new KeyValues("root");
	if (!FileToKeyValues(kv, buffer))
	{
		delete kv;
		LogError("Failed to load restricted weapons list! File not found!");
	}
	else
	{
		g_RestrictedWeaponsConfig = kv;
		LogSF2Message("Reloaded restricted weapons configuration file successfully");
	}
}

public Action Timer_RoundMessages(Handle timer)
{
	if (!g_Enabled) return Plugin_Stop;
	
	if (timer != g_hRoundMessagesTimer) return Plugin_Stop;
	
	switch (g_iRoundMessagesNum)
	{
		case 0:CPrintToChatAll("{royalblue}== {violet}Slender Fortress{royalblue} coded by {hotpink}KitRifty & Kenzzer{royalblue}==\n== Modified by {deeppink}Mentrillum & The Gaben{royalblue}, current version {violet}%s{royalblue}==", PLUGIN_VERSION_DISPLAY);
		case 1:CPrintToChatAll("%t", "SF2 Ad Message 1");
		case 2:CPrintToChatAll("%t", "SF2 Ad Message 2");
	}
	
	g_iRoundMessagesNum++;
	if (g_iRoundMessagesNum > 2)g_iRoundMessagesNum = 0;
	
	return Plugin_Continue;
}

public Action Timer_WelcomeMessage(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	CPrintToChat(client, "%T", "SF2 Welcome Message", client);
	
	return Plugin_Stop;
}

int GetMaxPlayersForRound()
{
	int iOverride = g_MaxPlayersOverrideConVar.IntValue;
	if (iOverride != -1) return iOverride;
	return g_MaxPlayersConVar.IntValue;
}

public void OnConVarChanged(Handle cvar, const char[] oldValue, const char[] intValue)
{
	if (cvar == g_DifficultyConVar)
	{
		switch (StringToInt(intValue))
		{
			case Difficulty_Easy: g_RoundDifficultyModifier = DIFFICULTYMODIFIER_NORMAL;
			case Difficulty_Hard: g_RoundDifficultyModifier = DIFFICULTYMODIFIER_HARD;
			case Difficulty_Insane: g_RoundDifficultyModifier = DIFFICULTYMODIFIER_INSANE;
			case Difficulty_Nightmare: g_RoundDifficultyModifier = DIFFICULTYMODIFIER_NIGHTMARE;
			case Difficulty_Apollyon:
			{
				if (g_RestartSessionEnabled) g_RoundDifficultyModifier = DIFFICULTYMODIFIER_RESTARTSESSION;
				else g_RoundDifficultyModifier = DIFFICULTYMODIFIER_APOLLYON;
			}
			default: g_RoundDifficultyModifier = DIFFICULTYMODIFIER_NORMAL;
		}
		CheckIfMusicValid();
		if (MusicActive() && !SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i) || !IsClientInGame(i) || IsClientSourceTV(i)) continue;
				
				char sPath[PLATFORM_MAX_PATH];
				GetBossMusic(sPath, sizeof(sPath));
				if (sPath[0] != '\0') StopSound(i, MUSIC_CHAN, sPath);
				ClientUpdateMusicSystem(i);
			}
		}
		ChangeAllSlenderModels();
		Call_StartForward(g_OnDifficultyChangeFwd);
		Call_PushCell(StringToInt(intValue));
		Call_Finish();
	}
	else if (cvar == g_MaxPlayersConVar || cvar == g_MaxPlayersOverrideConVar)
	{
		for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
		{
			CheckPlayerGroup(i);
		}
	}
	else if (cvar == g_PlayerShakeEnabledConVar)
	{
		g_IsPlayerShakeEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_PlayerViewbobHurtEnabledConVar)
	{
		g_bPlayerViewbobHurtEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_PlayerViewbobSprintEnabledConVar)
	{
		g_bPlayerViewbobSprintEnabled = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_GravityConVar)
	{
		g_Gravity = StringToFloat(intValue);
	}
	else if (cvar == g_20DollarsConVar)
	{
		g_20Dollars = view_as<bool>(StringToInt(intValue));
	}
	else if (cvar == g_AllChatConVar || SF_IsBoxingMap())
	{
		if (g_Enabled)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				ClientUpdateListeningFlags(i);
			}
		}
	}
	else if (cvar == g_IgnoreRoundWinConditionsConVar)
	{
		if (!view_as<bool>(StringToInt(intValue)) && !IsRoundInWarmup() && !IsRoundEnding())
		{
			CheckRoundWinConditions();
		}
	}
	else if (cvar == g_RestartSessionConVar)
	{
		if (g_RestartSessionConVar.BoolValue)
		{
			ArrayList hSelectableBossesAdmin = GetSelectableAdminBossProfileList().Clone();
			ArrayList hSelectableBosses = GetSelectableBossProfileList().Clone();
			for (int i = 0; i < sizeof(g_strSoundNightmareMode) - 1; i++)
			EmitSoundToAll(g_strSoundNightmareMode[i]);
			SpecialRoundGameText("Its Restart Session time!", "leaderboard_streak");
			CPrintToChatAll("{royalblue}%t{default}Your thirst for blood continues? Very well, let the blood spill. Let the demons feed off your unfortunate soul... Difficulty set to {mediumslateblue}%t!", "SF2 Prefix", "SF2 Calamity Difficulty");
			g_RestartSessionEnabled = true;
			g_DifficultyConVar.SetInt(Difficulty_Apollyon);
			g_IgnoreRoundWinConditionsConVar.SetBool(true);
			g_IgnoreRedPlayerDeathSwapConVar.SetBool(true);
			g_BossChaseEndlesslyConVar.SetBool(true);
			g_RoundDifficultyModifier = DIFFICULTYMODIFIER_RESTARTSESSION;
			if (g_hRoundGraceTimer != null)
			{
				TriggerTimer(g_hRoundGraceTimer);
			}
			for (int iBossCount = 0; iBossCount < 10; iBossCount++)
			{
				char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH], sBufferAdmin[SF2_MAX_PROFILE_NAME_LENGTH];
				if (hSelectableBosses.Length > 0)
				{
					hSelectableBosses.GetString(GetRandomInt(0, hSelectableBosses.Length - 1), sBuffer, sizeof(sBuffer));
					AddProfile(sBuffer);
				}
				if (hSelectableBossesAdmin.Length > 0)
				{
					hSelectableBossesAdmin.GetString(GetRandomInt(0, hSelectableBossesAdmin.Length - 1), sBufferAdmin, sizeof(sBufferAdmin));
					AddProfile(sBufferAdmin);
				}
			}
			for (int i = 1; i < MaxClients; i++)
			{
				if (!IsValidClient(i)) continue;
				if (IsClientSourceTV(i)) continue;
				if (!CheckCommandAccess(i, "sm_sf2_setplaystate", ADMFLAG_SLAY))
				{
					if (IsClientInGhostMode(i))
					{
						ClientSetGhostModeState(i, false);
						TF2_RespawnPlayer(i);
						TF2_RemoveCondition(i, TFCond_StealthedUserBuffFade);
						g_LastCommandTime[i] = GetEngineTime()+0.5;
						CreateTimer(0.25, Timer_ForcePlayer, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
					}
					else SetClientPlayState(i, true);
				}
				else SetClientPlayState(i, false);
			}
			if (IsRoundPlaying())
			{
				ArrayList hSpawnPoint = new ArrayList();
				float flTeleportPos[3];
				int ent = -1, iSpawnTeam = 0;
				while ((ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1)
				{
					iSpawnTeam = GetEntProp(ent, Prop_Data, "m_iInitialTeamNum");
					if (iSpawnTeam == TFTeam_Red)
					{
						hSpawnPoint.Push(ent);
					}
					
				}
				ent = -1;
				if (hSpawnPoint.Length > 0)
				{
					for (int npcIndex = 0; npcIndex < MAX_BOSSES; npcIndex++)
					{
						ent = hSpawnPoint.Get(GetRandomInt(0, hSpawnPoint.Length - 1));
						
						if (IsValidEntity(ent))
						{
							GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flTeleportPos);
							SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(npcIndex);
							if (!Npc.IsValid()) continue;
							SpawnSlender(Npc, flTeleportPos);
						}
					}
				}
				delete hSpawnPoint;
			}
			delete hSelectableBosses;
			delete hSelectableBossesAdmin;
		}
		else
		{
			CPrintToChatAll("{royalblue}%t{default}You're done? Ok. Difficulty set to {darkgray}Apollyon.", "SF2 Prefix");
			g_RestartSessionEnabled = false;
			g_DifficultyConVar.SetInt(Difficulty_Apollyon);
			g_IgnoreRoundWinConditionsConVar.SetBool(false);
			g_IgnoreRedPlayerDeathSwapConVar.SetBool(false);
			g_BossChaseEndlesslyConVar.SetBool(false);
			g_RoundDifficultyModifier = DIFFICULTYMODIFIER_APOLLYON;
		}
	}
}

//	==========================================================
//	IN-GAME AND ENTITY HOOK FUNCTIONS
//	==========================================================


public void OnEntityCreated(int ent, const char[] classname)
{
	if (!g_Enabled) return;
	
	if (!IsValidEntity(ent) || ent <= 0) return;
	
	if (strcmp(classname, "spotlight_end") == 0)
	{
		SDKHook(ent, SDKHook_SpawnPost, Hook_FlashlightEndSpawnPost);
	}
	else if (strcmp(classname, "beam") == 0)
	{
		SDKHook(ent, SDKHook_SetTransmit, Hook_FlashlightBeamSetTransmit);
	}
	else if (strncmp(classname, "item_healthkit_", 15) == 0 && !SF_IsBoxingMap())
	{
		SDKHook(ent, SDKHook_Touch, Hook_HealthKitOnTouch);
	}
	else if (strcmp(classname, "func_button") == 0)
	{
		SDKHook(ent, SDKHook_Touch, Hook_GhostNoTouch);
	}
	else if (strncmp(classname, "trigger_", 8) == 0)
	{
		SDKHook(ent, SDKHook_Touch, Hook_GhostNoTouch);
	}
	else if (strcmp(classname, "tf_dropped_weapon") == 0)
	{
		SDKHook(ent, SDKHook_SpawnPost, Hook_DeleteDroppedWeapon);
	}
	else if (strcmp(classname, "obj_sentrygun") == 0 || strcmp(classname, "obj_dispenser") == 0 || strcmp(classname, "obj_teleporter") == 0)
	{
		CreateTimer(0.1, Timer_FullyBuildBuilding, EntIndexToEntRef(ent), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
	PvP_OnEntityCreated(ent, classname);
}

public Action Timer_FullyBuildBuilding(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;

	int iBuilding = EntRefToEntIndex(entref);
	if (!iBuilding || iBuilding == INVALID_ENT_REFERENCE) return Plugin_Stop;

	int iBuilder = GetEntPropEnt(iBuilding, Prop_Send, "m_hBuilder");

	if (GetEntPropFloat(iBuilding, Prop_Send, "m_flPercentageConstructed") >= 1.0 && !GetEntProp(iBuilding, Prop_Send, "m_bCarried") &&
	IsValidClient(iBuilder))
	{
		char sBuilding[64];

		GetEntityClassname(iBuilding, sBuilding, sizeof(sBuilding));

		SetEntProp(iBuilding, Prop_Send, "m_iTeamNum", TFTeam_Boss);
		int iRandomLevel = GetRandomInt(1,1);
		int iHealth = 150;
		if (strcmp(sBuilding, "obj_sentrygun") == 0)
		{
			SetEntityModel(iBuilding,"models/buildables/sentry1.mdl");
		}
		else if (strcmp(sBuilding, "obj_dispenser") == 0)
		{
			SetEntityModel(iBuilding,"models/buildables/dispenser.mdl");
		}
		SetEntProp(iBuilding, Prop_Send, "m_iUpgradeLevel", iRandomLevel);
		SetEntProp(iBuilding, Prop_Send, "m_iHealth", iHealth);
		SetEntProp(iBuilding, Prop_Send, "m_iMaxHealth", iHealth);
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void Hook_DeleteDroppedWeapon(int ent)
{
	if (!g_Enabled) return;
	
	if (IsValidEntity(ent))
	{
		SDKUnhook(ent, SDKHook_SpawnPost, Hook_DeleteDroppedWeapon);
		RemoveEntity(ent);
	}
}

public MRESReturn Hook_WeaponGetCustomDamageType(int weapon, Handle hReturn, Handle hParams)
{
	if (!g_Enabled) return MRES_Ignored;
	
	int ownerEntity = GetEntPropEnt(weapon, Prop_Data, "m_hOwnerEntity");
	if (IsValidClient(ownerEntity) && IsClientInPvP(ownerEntity) && IsValidEntity(weapon) && ownerEntity)
	{
		int customDamageType = DHookGetReturn(hReturn);
		if (customDamageType != -1)
		{
			MRESReturn hookResult = PvP_GetWeaponCustomDamageType(weapon, ownerEntity, customDamageType);
			if (hookResult != MRES_Ignored)
			{
				DHookSetReturn(hReturn, customDamageType);
				return hookResult;
			}
		}
		else return MRES_Ignored;
	}
	else
	{
		return MRES_Ignored;
	}
	
	return MRES_Ignored;
}

public void OnEntityDestroyed(int ent)
{
	if (!g_Enabled) return;
	
	if (!IsValidEntity(ent) || ent <= 0) return;
	
	int bossIndex = NPCGetFromEntIndex(ent);
	if (bossIndex != -1)
	{
		RemoveSlender(bossIndex);
		return;
	}
	
	char sClassname[64];
	GetEntityClassname(ent, sClassname, sizeof(sClassname));
	
	if (strcmp(sClassname, "light_dynamic", false) == 0)
	{
		AcceptEntityInput(ent, "TurnOff");
		
		int iEnd = INVALID_ENT_REFERENCE;
		while ((iEnd = FindEntityByClassname(iEnd, "spotlight_end")) != -1)
		{
			if (GetEntPropEnt(iEnd, Prop_Data, "m_hOwnerEntity") == ent)
			{
				RemoveEntity(iEnd);
				break;
			}
		}
	}
	g_SlenderHitboxOwner[ent]=-1;
	
	PvP_OnEntityDestroyed(ent, sClassname);
}

public Action Hook_BlockUserMessage(UserMsg msg_id, Handle bf, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!g_Enabled) return Plugin_Continue;
	return Plugin_Handled;
}

public Action Hook_TauntUserMessage(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!g_Enabled) return Plugin_Continue;
	
	int client = msg.ReadByte();
	if (!g_PlayerEliminated[client]) return Plugin_Handled; //Don't allow a red player to play a taunt sound
	if (g_PlayerProxy[client]) return Plugin_Handled; //Don't allow proxies to play a taunt sound
	
	char sTauntSound[PLATFORM_MAX_PATH];
	msg.ReadString(sTauntSound, PLATFORM_MAX_PATH);
	
	DataPack dataTaunt = new DataPack();
	dataTaunt.WriteCell(client);
	dataTaunt.WriteString(sTauntSound);
	
	RequestFrame(Frame_SendNewTauntMessage, dataTaunt); //Resend taunt sound to eliminated players only
	
	return Plugin_Handled; //Never ever allow a red player/proxy to hear taunt sound, we keep the playing area "tauntmusicless"
}

public void Frame_SendNewTauntMessage(DataPack dataMessage)
{
	int players[MAXPLAYERS + 1];
	int playersNum;
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client)) continue;
		if (g_PlayerProxy[client]) continue;
		if (!g_PlayerEliminated[client] && !DidClientEscape(client)) continue;
		players[playersNum++] = client;
	}
	
	dataMessage.Reset();
	
	BfWrite message = UserMessageToBfWrite(StartMessage("PlayerTauntSoundLoopStart", players, playersNum, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS));
	message.WriteByte(dataMessage.ReadCell());
	char sTauntSound[PLATFORM_MAX_PATH];
	dataMessage.ReadString(sTauntSound, sizeof(sTauntSound));
	message.WriteString(sTauntSound);
	delete message;
	EndMessage();
	delete dataMessage;
}

public Action Hook_BlockUserMessageEx(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!g_Enabled) return Plugin_Continue;
	
	char message[32];
	msg.ReadByte();
	msg.ReadByte();
	msg.ReadString(message, sizeof(message));
	
	if (strcmp(message, "#TF_Name_Change") == 0)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Hook_NormalSound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (!g_Enabled) return Plugin_Continue;
	
	int difficulty = g_DifficultyConVar.IntValue;

	if (IsValidClient(entity))
	{
		if (IsClientInGhostMode(entity))
		{
			switch (channel)
			{
				case SNDCHAN_VOICE, SNDCHAN_WEAPON, SNDCHAN_ITEM, SNDCHAN_BODY: return Plugin_Handled;
			}
			if (!StrContains(sample, "player/footsteps", false) || StrContains(sample, "step", false) != -1)
			{
				sample = NULLSOUND;
				return Plugin_Changed;
			}
		}
		else if (g_PlayerProxy[entity])
		{
			int iMaster = NPCGetFromUniqueID(g_PlayerProxyMaster[entity]);
			if (iMaster != -1)
			{
				char profile[SF2_MAX_PROFILE_NAME_LENGTH];
				NPCGetProfile(iMaster, profile, sizeof(profile));
				
				switch (channel)
				{
					case SNDCHAN_VOICE:
					{
						if (!g_SlenderProxiesAllowNormalVoices[iMaster])
						{
							return Plugin_Handled;
						}
					}
				}
			}
		}
		else if (!g_PlayerEliminated[entity] && !g_PlayerEscaped[entity])
		{
			switch (channel)
			{
				case SNDCHAN_VOICE:
				{
					if (IsRoundInIntro()) return Plugin_Handled;
					if (!StrContains(sample, "vo/halloween_scream")) return Plugin_Handled;
					
					for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
					{
						if (NPCGetUniqueID(bossIndex) == -1) continue;
						
						if (SlenderCanHearPlayer(bossIndex, entity, SoundType_Voice) && NPCShouldHearEntity(bossIndex, entity, SoundType_Voice))
						{
							GetClientAbsOrigin(entity, g_SlenderTargetSoundTempPos[bossIndex]);
							g_SlenderInterruptConditions[bossIndex] |= COND_HEARDSUSPICIOUSSOUND;
							g_SlenderInterruptConditions[bossIndex] |= COND_HEARDVOICE;
							if (g_SlenderState[bossIndex] == STATE_ALERT && NPCChaserIsAutoChaseEnabled(bossIndex) && g_SlenderAutoChaseCooldown[bossIndex] < GetGameTime())
							{
								g_SlenderSoundTarget[bossIndex] = EntIndexToEntRef(entity);
								g_SlenderAutoChaseCount[bossIndex] += NPCChaserAutoChaseAddVoice(bossIndex, difficulty);
								g_SlenderAutoChaseCooldown[bossIndex] = GetGameTime() + 0.3;
							}
						}
					}
				}
				case SNDCHAN_BODY:
				{
					if (!StrContains(sample, "player/footsteps", false) || StrContains(sample, "step", false) != -1)
					{
						if (g_PlayerViewbobSprintEnabledConVar.BoolValue && IsClientReallySprinting(entity))
						{
							// Viewpunch.
							float flPunchVelStep[3];
							
							float flVelocity[3];
							GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", flVelocity);
							float flSpeed = GetVectorLength(flVelocity, true);
							
							flPunchVelStep[0] = (flSpeed / SquareFloat(300.0));
							flPunchVelStep[1] = 0.0;
							flPunchVelStep[2] = 0.0;
							
							ClientViewPunch(entity, flPunchVelStep);
						}
						
						for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
						{
							if (NPCGetUniqueID(bossIndex) == -1) continue;
							
							if (SlenderCanHearPlayer(bossIndex, entity, SoundType_Footstep) && NPCShouldHearEntity(bossIndex, entity, SoundType_Footstep))
							{
								GetClientAbsOrigin(entity, g_SlenderTargetSoundTempPos[bossIndex]);
								g_SlenderInterruptConditions[bossIndex] |= COND_HEARDSUSPICIOUSSOUND;
								g_SlenderInterruptConditions[bossIndex] |= COND_HEARDFOOTSTEP;
								if (g_SlenderState[bossIndex] == STATE_ALERT && NPCChaserIsAutoChaseEnabled(bossIndex) && g_SlenderAutoChaseCooldown[bossIndex] < GetGameTime())
								{
									g_SlenderSoundTarget[bossIndex] = EntIndexToEntRef(entity);
									if (!IsClientReallySprinting(entity)) g_SlenderAutoChaseCount[bossIndex] += NPCChaserAutoChaseAddFootstep(bossIndex, difficulty);
									else if (IsClientReallySprinting(entity) && NPCChaserCanAutoChaseSprinters(bossIndex)) g_SlenderAutoChaseCount[bossIndex] += NPCChaserAutoChaseAddFootstep(bossIndex, difficulty) * 3;
									g_SlenderAutoChaseCooldown[bossIndex] = GetGameTime() + 0.3;
								}
								
								if (IsClientSprinting(entity) && !(GetEntProp(entity, Prop_Send, "m_bDucking") || GetEntProp(entity, Prop_Send, "m_bDucked")))
								{
									g_SlenderInterruptConditions[bossIndex] |= COND_HEARDFOOTSTEPLOUD;
								}
							}
						}
					}
				}
				case SNDCHAN_ITEM, SNDCHAN_WEAPON:
				{
					if (StrContains(sample, "swing", false) || StrContains(sample, "impact", false) != -1 || StrContains(sample, "hit", false) != -1 || StrContains(sample, "slice", false) != -1 || StrContains(sample, "reload", false) != -1 || StrContains(sample, "woosh", false) != -1 || StrContains(sample, "eviction", false) != -1 || StrContains(sample, "holy", false) != -1)
					{
						for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
						{
							if (NPCGetUniqueID(bossIndex) == -1) continue;
							
							if (SlenderCanHearPlayer(bossIndex, entity, SoundType_Weapon) && NPCShouldHearEntity(bossIndex, entity, SoundType_Weapon))
							{
								GetClientAbsOrigin(entity, g_SlenderTargetSoundTempPos[bossIndex]);
								g_SlenderInterruptConditions[bossIndex] |= COND_HEARDSUSPICIOUSSOUND;
								g_SlenderInterruptConditions[bossIndex] |= COND_HEARDWEAPON;
								if (g_SlenderState[bossIndex] == STATE_ALERT && NPCChaserIsAutoChaseEnabled(bossIndex) && g_SlenderAutoChaseCooldown[bossIndex] < GetGameTime())
								{
									g_SlenderSoundTarget[bossIndex] = EntIndexToEntRef(entity);
									g_SlenderAutoChaseCount[bossIndex] += NPCChaserAutoChaseAddWeapon(bossIndex, difficulty);
									g_SlenderAutoChaseCooldown[bossIndex] = GetGameTime() + 0.3;
								}
							}
						}
					}
				}
				case SNDCHAN_STATIC:
				{
					if (StrContains(sample, FLASHLIGHT_CLICKSOUND, false) != -1)
					{
						for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
						{
							if (NPCGetUniqueID(bossIndex) == -1) continue;
							
							if (SlenderCanHearPlayer(bossIndex, entity, SoundType_Flashlight) && NPCShouldHearEntity(bossIndex, entity, SoundType_Flashlight))
							{
								GetClientAbsOrigin(entity, g_SlenderTargetSoundTempPos[bossIndex]);
								g_SlenderInterruptConditions[bossIndex] |= COND_HEARDSUSPICIOUSSOUND;
								g_SlenderInterruptConditions[bossIndex] |= COND_HEARDFLASHLIGHT;
								if (g_SlenderState[bossIndex] == STATE_ALERT && NPCChaserIsAutoChaseEnabled(bossIndex) && g_SlenderAutoChaseCooldown[bossIndex] < GetGameTime())
								{
									g_SlenderSoundTarget[bossIndex] = EntIndexToEntRef(entity);
									g_SlenderAutoChaseCount[bossIndex] += NPCChaserAutoChaseAddWeapon(bossIndex, difficulty);
									g_SlenderAutoChaseCooldown[bossIndex] = GetGameTime() + 0.3;
								}
							}
						}
					}
					if (StrContains(sample, "happy_birthday_tf", false) != -1 || StrContains(sample, "jingle_bells_nm", false) != -1)
					{
						for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
						{
							if (NPCGetUniqueID(bossIndex) == -1) continue;
							
							if (SlenderCanHearPlayer(bossIndex, entity, SoundType_Voice) && NPCShouldHearEntity(bossIndex, entity, SoundType_Voice))
							{
								GetClientAbsOrigin(entity, g_SlenderTargetSoundTempPos[bossIndex]);
								g_SlenderInterruptConditions[bossIndex] |= COND_HEARDSUSPICIOUSSOUND;
								g_SlenderInterruptConditions[bossIndex] |= COND_HEARDVOICE;
								if (g_SlenderState[bossIndex] == STATE_ALERT && NPCChaserIsAutoChaseEnabled(bossIndex) && g_SlenderAutoChaseCooldown[bossIndex] < GetGameTime())
								{
									g_SlenderSoundTarget[bossIndex] = EntIndexToEntRef(entity);
									g_SlenderAutoChaseCount[bossIndex] += NPCChaserAutoChaseAddVoice(bossIndex, difficulty) * 2;
									g_SlenderAutoChaseCooldown[bossIndex] = GetGameTime() + 0.3;
								}
							}
						}
					}
				}
			}
		}
	}
	
	if (IsValidEntity(entity))
	{
		char classname[64];
		if (GetEntityClassname(entity, classname, sizeof(classname)) && strcmp(classname, "tf_projectile_rocket") == 0 && ((ProjectileGetFlags(entity) & PROJ_ICEBALL) || (ProjectileGetFlags(entity) & PROJ_FIREBALL) || (ProjectileGetFlags(entity) & PROJ_ICEBALL_ATTACK) || (ProjectileGetFlags(entity) & PROJ_FIREBALL_ATTACK)))
		{
			if (strcmp(sample, EXPLOSIVEDANCE_EXPLOSION1, false) == 0 || strcmp(sample, EXPLOSIVEDANCE_EXPLOSION2, false) == 0 || strcmp(sample, EXPLOSIVEDANCE_EXPLOSION3, false) == 0)
			{
				sample = NULLSOUND;
				return Plugin_Changed;
			}
		}
	}
	
	bool bModified = false;
	
	/*for (int i = 0; i < numClients; i++)
	{
		int client = clients[i];
		if (IsValidClient(client) && IsPlayerAlive(client) && !IsClientInGhostMode(client))
		{
			bool bCanHearSound = true;
			
			if (IsValidClient(entity) && entity != client)
			{
				if (!g_PlayerEliminated[client])
				{
					if (g_IsSpecialRound && SF_SpecialRound(SPECIALROUND_SINGLEPLAYER))
					{
						if (!g_PlayerEliminated[entity] && !DidClientEscape(entity))
						{
							bCanHearSound = false;
						}
					}
				}
			}
			
			if (!bCanHearSound)
			{
				bModified = true;
				clients[i] = -1;
			}
		}
	}*/
	
	if (bModified) return Plugin_Changed;
	return Plugin_Continue;
}

public MRESReturn Hook_EntityShouldTransmit(int entity, Handle hReturn, Handle hParams)
{
	if (!g_Enabled) return MRES_Ignored;
	
	if (IsValidClient(entity))
	{
		if (DoesClientHaveConstantGlow(entity))
		{
			DHookSetReturn(hReturn, FL_EDICT_ALWAYS); // Should always transmit, but our SetTransmit hook gets the final say.
			return MRES_Supercede;
		}
		else if (IsClientInGhostMode(entity))
		{
			DHookSetReturn(hReturn, FL_EDICT_DONTSEND);
			return MRES_Supercede;
		}
	}
	else
	{
		DHookSetReturn(hReturn, FL_EDICT_ALWAYS); // Should always transmit, but our SetTransmit hook gets the final say.
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
}

void SF_CollectTriggersMultiple()
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "trigger_*")) != -1)
	{
		SDKHook(ent, SDKHook_StartTouch, Hook_TriggerOnStartTouchEx);
		SDKHook(ent, SDKHook_Touch, Hook_TriggerOnTouchEx);
		SDKHook(ent, SDKHook_EndTouch, Hook_TriggerOnEndTouchEx);
	}
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "func*")) != -1)
	{
		SDKHook(ent, SDKHook_StartTouch, Hook_FuncOnStartTouchEx);
		SDKHook(ent, SDKHook_Touch, Hook_FuncOnTouchEx);
		SDKHook(ent, SDKHook_EndTouch, Hook_FuncOnEndTouchEx);
	}
}
public Action Hook_TriggerOnStartTouchEx(int iTrigger, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	Hook_TriggerOnStartTouch("OnStartTouch", iTrigger, iOther, 0.0);
	return Plugin_Continue;
}

public Action Hook_TriggerOnTouchEx(int iTrigger, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	return Plugin_Continue;
}

public Action Hook_TriggerOnEndTouchEx(int iTrigger, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	Hook_TriggerOnEndTouch("OnEndTouch", iTrigger, iOther, 0.0);
	return Plugin_Continue;
}

public Action Hook_FuncOnStartTouchEx(int iFunc, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	return Plugin_Continue;
}

public Action Hook_FuncOnTouchEx(int iFunc, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	return Plugin_Continue;
}

public Action Hook_FuncOnEndTouchEx(int iFunc, int iOther)
{
	if (MaxClients >= iOther >= 1 && IsClientInGhostMode(iOther)) return Plugin_Handled;
	return Plugin_Continue;
}

public void Hook_TriggerOnStartTouch(const char[] output, int caller, int activator, float delay)
{
	if (!g_Enabled) return;
	
	if (!IsValidEntity(caller)) return;
	
	char sName[64];
	GetEntPropString(caller, Prop_Data, "m_iName", sName, sizeof(sName));
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0)LogSF2Message("[SF2 TRIGGERS LOG] Trigger %i (trigger_multiple) %s start touch by %i (%s)!", caller, sName, activator, IsValidClient(activator) ? "Player" : "Entity");
	#endif	
	if (StrContains(sName, "sf2_escape_trigger", false) == 0)
	{
		if (IsRoundInEscapeObjective() && !g_RestartSessionEnabled)
		{
			if (IsValidClient(activator) && IsPlayerAlive(activator) && !IsClientInDeathCam(activator) && !g_PlayerEliminated[activator] && !DidClientEscape(activator))
			{
				ClientEscape(activator);
				TeleportClientToEscapePoint(activator);
			}
		}
	}
	
	PvP_OnTriggerStartTouch(caller, activator);
}

public void Hook_TriggerOnEndTouch(const char[] sOutput, int caller, int activator, float flDelay)
{
	if (!g_Enabled) return;
	
	if (!IsValidEntity(caller)) return;
	
	char sName[64];
	GetEntPropString(caller, Prop_Data, "m_iName", sName, sizeof(sName));
	#if defined DEBUG	
	if (g_DebugDetailConVar.IntValue > 0)LogSF2Message("[SF2 TRIGGERS LOG] Trigger %i (trigger_multiple) %s end touch by %i (%s)!", caller, sName, activator, IsValidClient(activator) ? "Player" : "Entity");
	#endif
}

public void Hook_TriggerTeleportOnStartTouch(const char[] output, int caller, int activator, float delay)
{
	if (!g_Enabled) return;
	
	if (!IsValidEntity(caller)) return;
	
	int flags = GetEntProp(caller, Prop_Data, "m_spawnflags");
	if (((flags & TRIGGER_CLIENTS) && (flags & TRIGGER_NPCS)) || (flags & TRIGGER_EVERYTHING_BUT_PHYSICS_DEBRIS))
	{
		if (IsValidClient(activator))
		{
			bool bChase = ClientHasMusicFlag(activator, MUSICF_CHASE);
			if (bChase)
			{
				// The player took a teleporter and is chased, and the boss can take it too, add the teleporter to the temp boss' goals.
				for (int i = 0; i < MAX_BOSSES; i++)
				{
					if (NPCGetUniqueID(i) == -1) continue;
					if (EntRefToEntIndex(g_SlenderTarget[i]) == activator)
					{
						if (NPCGetType(i) == SF2BossType_Statue)
						{
							for (int ii = 0; ii < MAX_NPCTELEPORTER; ii++)
							{
								if (NPCStatueGetTeleporter(i, ii) == INVALID_ENT_REFERENCE)
								{
									NPCStatueSetTeleporter(i, ii, EntIndexToEntRef(caller));
									break;
								}
							}
						}
						else
						{
							for (int ii = 0; ii < MAX_NPCTELEPORTER; ii++)
							{
								if (NPCChaserGetTeleporter(i, ii) == INVALID_ENT_REFERENCE)
								{
									NPCChaserSetTeleporter(i, ii, EntIndexToEntRef(caller));
									break;
								}
							}
						}
					}
				}
			}
			return;
		}
		SF2NPC_Chaser NpcChaser = view_as<SF2NPC_Chaser>(NPCGetFromEntIndex(activator));
		if (NpcChaser.IsValid())
		{
			//A boss took a teleporter
			int iTeleporter = NpcChaser.GetTeleporter(0);
			if (iTeleporter == EntIndexToEntRef(caller)) //Remove our temp goal, and go back chase our target! GRAAAAAAAAAAAAh! Unless we have some other teleporters to take....fak.
				NpcChaser.SetTeleporter(0, INVALID_ENT_REFERENCE);
			if (MAX_NPCTELEPORTER > 2 && NpcChaser.GetTeleporter(1) != INVALID_ENT_REFERENCE)
			{
				for (int i = 0; i + 1 < MAX_NPCTELEPORTER; i++)
				{
					if (NpcChaser.GetTeleporter(i + 1) != INVALID_ENT_REFERENCE)
						NpcChaser.SetTeleporter(i, NpcChaser.GetTeleporter(i + 1));
					else
						NpcChaser.SetTeleporter(i, INVALID_ENT_REFERENCE);
				}
			}
		}
		SF2NPC_Statue NpcStatue = view_as<SF2NPC_Statue>(NPCGetFromEntIndex(activator));
		if (NpcStatue.IsValid())
		{
			//A boss took a teleporter
			int iTeleporter = NpcStatue.GetTeleporter(0);
			if (iTeleporter == EntIndexToEntRef(caller)) //Remove our temp goal, and go back chase our target! GRAAAAAAAAAAAAh! Unless we have some other teleporters to take....fak.
				NpcStatue.SetTeleporter(0, INVALID_ENT_REFERENCE);
			if (MAX_NPCTELEPORTER > 2 && NpcStatue.GetTeleporter(1) != INVALID_ENT_REFERENCE)
			{
				for (int i = 0; i + 1 < MAX_NPCTELEPORTER; i++)
				{
					if (NpcStatue.GetTeleporter(i + 1) != INVALID_ENT_REFERENCE)
						NpcStatue.SetTeleporter(i, NpcStatue.GetTeleporter(i + 1));
					else
						NpcStatue.SetTeleporter(i, INVALID_ENT_REFERENCE);
				}
			}
		}
	}
	if (IsValidClient(activator))
	{
		bool bChase = ClientHasMusicFlag(activator, MUSICF_CHASE);
		if (bChase)
		{
			// The player took a teleporter and is chased, but the boss can't follow.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (NPCGetUniqueID(i) == -1) continue;
				if (EntRefToEntIndex(g_SlenderTarget[i]) == activator)
				{
					g_SlenderGiveUp[i] = true;
				}
			}
		}
	}
}
public Action Hook_PageOnTakeDamage(int page, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!g_Enabled) return Plugin_Continue;
	
	if (g_RestartSessionEnabled) return Plugin_Continue;
	
	if (IsValidClient(attacker))
	{
		if (!g_PlayerEliminated[attacker])
		{
			if (damagetype & 0x80) // 0x80 == melee damage
			{
				CollectPage(page, attacker);
			}
		}
	}
	
	return Plugin_Continue;
}

void CollectPage(int page, int activator)
{
	if (SF_SpecialRound(SPECIALROUND_ESCAPETICKETS))
	{
		ClientEscape(activator);
		TeleportClientToEscapePoint(activator);
	}
	
	if (SF_SpecialRound(SPECIALROUND_PAGEREWARDS) && !g_bPlayerGettingPageReward[activator])
	{
		g_hPlayerPageRewardTimer[activator] = CreateTimer(3.0, Timer_GiveRandomPageReward, EntIndexToEntRef(activator), TIMER_FLAG_NO_MAPCHANGE);
		g_bPlayerGettingPageReward[activator] = true;
		EmitRollSound(activator);
	}
	
	if (SF_SpecialRound(SPECIALROUND_BOSSROULETTE))
	{
		char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH], sBossName[SF2_MAX_NAME_LENGTH];
		if (NPCGetCount() < 31)
		{
			if (g_DifficultyConVar.IntValue < 4 || GetSelectableAdminBossProfileList().Length <= 0)
			{
				ArrayList hSelectableBosses = GetSelectableBossProfileList().Clone();
				if (hSelectableBosses.Length > 0)
				{
					hSelectableBosses.GetString(GetRandomInt(0, hSelectableBosses.Length - 1), sBuffer, sizeof(sBuffer));
					AddProfile(sBuffer);
					NPCGetBossName(_, sBossName, sizeof(sBossName), sBuffer);
					EmitSoundToAll(SR_SOUND_SELECT_BR, _, SNDCHAN_AUTO, _, _, 0.75);
					SpecialRoundGameText(sBossName, "d_purgatory");
				}
				delete hSelectableBosses;
			}
			else
			{
				ArrayList hSelectableBosses = GetSelectableAdminBossProfileList().Clone();
				if (hSelectableBosses.Length > 0)
				{
					hSelectableBosses.GetString(GetRandomInt(0, hSelectableBosses.Length - 1), sBuffer, sizeof(sBuffer));
					AddProfile(sBuffer);
					NPCGetBossName(_, sBossName, sizeof(sBossName), sBuffer);
					EmitSoundToAll(SR_SOUND_SELECT_BR, _, SNDCHAN_AUTO, _, _, 0.75);
					SpecialRoundGameText(sBossName, "d_purgatory");
				}
				delete hSelectableBosses;
			}
		}
		else
		{
			SpecialRoundGameText("You got lucky, no boss can be added.", "cappoint_progressbar_blocked");
		}
	}
	
	if (SF_SpecialRound(SPECIALROUND_THANATOPHOBIA) && g_PageMax <= 8)
	{
		for (int iReds = 1; iReds <= MaxClients; iReds++)
		{
			if (!IsValidClient(iReds) || 
				g_PlayerEliminated[iReds] || 
				DidClientEscape(iReds) || 
				GetClientTeam(iReds) != TFTeam_Red || 
				!IsPlayerAlive(iReds)) continue;
			int iMaxHealth = SDKCall(g_hSDKGetMaxHealth, iReds);
			float healthToRecover = float(iMaxHealth) / 10.0;
			int iHealthToRecover = RoundToNearest(healthToRecover) + GetEntProp(iReds, Prop_Send, "m_iHealth");
			SetEntityHealth(iReds, iHealthToRecover);
		}
	}
	
	SetPageCount(g_PageCount + 1);
	g_PlayerPageCount[activator] += 1;
	// Play page collect sound
	char sPageCollectSound[PLATFORM_MAX_PATH];
	int iPageCollectionSoundPitch = g_iPageSoundPitch;
	if (SF_SpecialRound(SPECIALROUND_DUCKS))
	{
		// Ducks!
		int iRandomSound = GetRandomInt(0, sizeof(g_sPageCollectDuckSounds) - 1);
		strcopy(sPageCollectSound, sizeof(sPageCollectSound), g_sPageCollectDuckSounds[iRandomSound]);
	}
	else
	{
		strcopy(sPageCollectSound, sizeof(sPageCollectSound), g_strPageCollectSound);
		
		if (IsValidEntity(page))
		{
			int iPageIndex = g_Pages.FindValue(EnsureEntRef(page));
			if (iPageIndex != -1)
			{
				SF2PageEntityData pageData;
				g_Pages.GetArray(iPageIndex, pageData, sizeof(pageData));
				
				if (pageData.CollectSound[0] != '\0')
					strcopy(sPageCollectSound, sizeof(sPageCollectSound), pageData.CollectSound);
				
				if (pageData.CollectSoundPitch > 0)
					iPageCollectionSoundPitch = pageData.CollectSoundPitch;
			}
		}
	}
	
	EmitSoundToAll(sPageCollectSound, activator, SNDCHAN_ITEM, SNDLEVEL_SCREAMING, _, _, iPageCollectionSoundPitch);
	
	Call_StartForward(g_OnClientCollectPageFwd);
	Call_PushCell(page);
	Call_PushCell(activator);
	Call_Finish();
	
	// Gives points. Credit to the makers of VSH/FF2.
	Handle hEvent = CreateEvent("player_escort_score", true);
	SetEventInt(hEvent, "player", activator);
	SetEventInt(hEvent, "points", 1);
	FireEvent(hEvent);
	
	int iPage2 = GetEntPropEnt(page, Prop_Send, "m_hOwnerEntity");
	if (iPage2 > MaxClients)
		RemoveEntity(iPage2);
	else
	{
		iPage2 = GetEntPropEnt(page, Prop_Send, "m_hEffectEntity");
		if (iPage2 > MaxClients)
			RemoveEntity(iPage2);
	}
	
	AcceptEntityInput(page, "FireUser1");
	AcceptEntityInput(page, "KillHierarchy");
}

static void EmitRollSound(int client)
{
	EmitSoundToClient(client, GENERIC_ROLL_TICK_1, client);
	CreateTimer(0.12, Timer_RollTick_Case2, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RollTick_Case1(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case2, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case2(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case3, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case3(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case4, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case4(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case5, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case5(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case6, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case6(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case7, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case7(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case8, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case8(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case9, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case9(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.1, Timer_RollTick_Case10, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case10(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.3, Timer_RollTick_Case11, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case11(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.3, Timer_RollTick_Case12, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case12(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.3, Timer_RollTick_Case13, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case13(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_2, player);
	g_hPlayerPageRewardCycleTimer[player] = CreateTimer(0.5, Timer_RollTick_Case14, EntIndexToEntRef(player), TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_RollTick_Case14(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	EmitSoundToClient(player, GENERIC_ROLL_TICK_1, player);
	
	return Plugin_Stop;
}

public Action Timer_GiveRandomPageReward(Handle timer, any entref)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int player = EntRefToEntIndex(entref);
	if (!player || player == INVALID_ENT_REFERENCE) return Plugin_Stop;
	
	if (timer != g_hPlayerPageRewardTimer[player]) return Plugin_Stop;
	
	g_bPlayerGettingPageReward[player] = false;
	
	int iEffect = GetRandomInt(0, 11);
	switch (iEffect)
	{
		case 1:
		{
			TF2_IgnitePlayer(player, player);
		}
		case 2:
		{
			TF2_RegeneratePlayer(player);
		}
		case 3:
		{
			TF2_StunPlayer(player, 5.0, _, TF_STUNFLAG_BONKSTUCK);
		}
		case 4:
		{
			TF2_AddCondition(player, TFCond_CritOnFirstBlood, 8.0);
			EmitSoundToClient(player, CRIT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 5:
		{
			TF2_MakeBleed(player, player, 8.0);
			EmitSoundToClient(player, BLEED_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 6:
		{
			int iRareEffect = GetRandomInt(0, 30);
			switch (iRareEffect)
			{
				case 1, 2, 3, 4, 5:
				{
					int iDeathEffect = GetRandomInt(1, 3);
					switch (iDeathEffect)
					{
						case 1:
						{
							EmitSoundToAll(EXPLODE_PLAYER, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
							SDKHooks_TakeDamage(player, player, player, 9001.0, 262272, _, view_as<float>( { 0.0, 0.0, 0.0 } ));
						}
						case 2:
						{
							EmitSoundToAll(FIREWORK_START, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
							float fPush[3], flPlayerPos[3];
							GetClientAbsOrigin(player, flPlayerPos);
							flPlayerPos[2] += 10.0;
							fPush[2] = 4096.0;
							TeleportEntity(player, flPlayerPos, NULL_VECTOR, fPush);
							
							int iParticle = AttachParticle(player, FIREWORK_PARTICLE);
							CreateTimer(0.5, Timer_KillEntity, iParticle, TIMER_FLAG_NO_MAPCHANGE);
							
							CreateTimer(0.5, Timer_Firework_Explode, GetClientUserId(player), TIMER_FLAG_NO_MAPCHANGE);
						}
						case 3:
						{
							// define where the lightning strike ends
							float clientpos[3];
							GetClientAbsOrigin(player, clientpos);
							clientpos[2] -= 26; // increase y-axis by 26 to strike at player's chest instead of the ground
							
							// get random numbers for the x and y starting positions
							int randomx = GetRandomInt(-500, 500);
							int randomy = GetRandomInt(-500, 500);
							
							// define where the lightning strike starts
							float startpos[3];
							startpos[0] = clientpos[0] + randomx;
							startpos[1] = clientpos[1] + randomy;
							startpos[2] = clientpos[2] + 800;
							
							// define the color of the strike
							int color[4];
							color[0] = 255;
							color[1] = 255;
							color[2] = 255;
							color[3] = 255;
							
							// define the direction of the sparks
							float dir[3];
							
							TE_SetupBeamPoints(startpos, clientpos, g_LightningSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
							TE_SendToAll();
							
							TE_SetupSparks(clientpos, dir, 5000, 1000);
							TE_SendToAll();
							
							TE_SetupEnergySplash(clientpos, dir, false);
							TE_SendToAll();
							
							TE_SetupSmoke(clientpos, g_SmokeSprite, 5.0, 10);
							TE_SendToAll();
							
							CreateTimer(0.01, Timer_AshRagdoll, GetClientUserId(player), TIMER_FLAG_NO_MAPCHANGE);
							
							SDKHooks_TakeDamage(player, player, player, 9001.0, 1048576, _, view_as<float>( { 0.0, 0.0, 0.0 } ));
							
							EmitAmbientSound(SOUND_THUNDER, startpos, player, SNDLEVEL_RAIDSIREN);
						}
					}
				}
				case 6:
				{
					TF2_IgnitePlayer(player, player);
				}
				case 7:
				{
					TF2_RegeneratePlayer(player);
				}
				case 8:
				{
					TF2_StunPlayer(player, 5.0, _, TF_STUNFLAG_BONKSTUCK);
				}
				case 9:
				{
					TF2_AddCondition(player, TFCond_CritOnFirstBlood, 8.0);
					EmitSoundToClient(player, CRIT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 14:
				{
					TF2_MakeBleed(player, player, 10.0);
					EmitSoundToClient(player, BLEED_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 10, 11, 12, 13:
				{
					TF2_AddCondition(player, TFCond_UberchargedCanteen, 5.0);
					EmitSoundToClient(player, UBER_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 15, 16:
				{
					EmitSoundToClient(player, LOSE_SPRINT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
					g_PlayerSprintPoints[player] = 0;
				}
				case 17:
				{
					TF2_AddCondition(player, TFCond_Jarated, 10.0);
					EmitSoundToClient(player, JARATE_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 18:
				{
					TF2_AddCondition(player, TFCond_Gas, 10.0);
					EmitSoundToClient(player, GAS_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 19:
				{
					TF2_AddCondition(player, TFCond_SpeedBuffAlly, 5.0);
				}
				case 20:
				{
					TF2_AddCondition(player, TFCond_CritCola, 16.0);
					EmitSoundToClient(player, MINICRIT_BUFF, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 21:
				{
					TF2_AddCondition(player, TFCond_DefenseBuffed, 10.0);
					EmitSoundToClient(player, MINICRIT_BUFF, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				case 22:
				{
					TF2_AddCondition(player, TFCond_HalloweenQuickHeal, 3.0);
					TF2_AddCondition(player, TFCond_UberchargedCanteen, 1.0);
					EmitSoundToClient(player, UBER_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
				default:
				{
					EmitSoundToClient(player, NO_EFFECT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
				}
			}
		}
		case 7:
		{
			TF2_AddCondition(player, TFCond_Jarated, 10.0);
			EmitSoundToClient(player, JARATE_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 8:
		{
			TF2_AddCondition(player, TFCond_Gas, 10.0);
			EmitSoundToClient(player, GAS_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 9:
		{
			TF2_AddCondition(player, TFCond_SpeedBuffAlly, 5.0);
		}
		case 10:
		{
			TF2_AddCondition(player, TFCond_CritCola, 16.0);
			EmitSoundToClient(player, MINICRIT_BUFF, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 11:
		{
			TF2_AddCondition(player, TFCond_DefenseBuffed, 10.0);
			EmitSoundToClient(player, MINICRIT_BUFF, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		case 12:
		{
			TF2_AddCondition(player, TFCond_HalloweenQuickHeal, 3.0);
			TF2_AddCondition(player, TFCond_UberchargedCanteen, 1.0);
			EmitSoundToClient(player, UBER_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
		default:
		{
			EmitSoundToClient(player, NO_EFFECT_ROLL, player, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		}
	}
	g_hPlayerPageRewardTimer[player] = null;
	g_hPlayerPageRewardCycleTimer[player] = null;
	
	return Plugin_Stop;
}

public Action Timer_Firework_Explode(Handle hTimer, int iUserId) {
	int client = GetClientOfUserId(iUserId);
	if (!client) return Plugin_Stop;
	
	EmitSoundToAll(FIREWORK_EXPLOSION, client);
	SDKHooks_TakeDamage(client, client, client, 9001.0, 1327104, _, view_as<float>( { 0.0, 0.0, 0.0 } ));
	return Plugin_Stop;
}

//	==========================================================
//	GENERIC client HOOKS AND FUNCTIONS
//	==========================================================


public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!g_Enabled) return Plugin_Continue;
	
	bool bChanged = false;
	
	// Check impulse (block spraying and built-in flashlight)
	switch (impulse)
	{
		case 100:
		{
			impulse = 0;
		}
		case 201, 202:
		{
			if (IsClientInGhostMode(client))
			{
				impulse = 0;
			}
		}
	}
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		int button = (1 << i);
		
		if ((buttons & button))
		{
			if (!(g_iPlayerLastButtons[client] & button))
			{
				AFK_SetTime(client);
				ClientOnButtonPress(client, button);
				if (button == IN_ATTACK2)
				{
					if (IsClientInPvP(client) && !(buttons & IN_ATTACK))
					{
						if (TF2_GetPlayerClass(client) == TFClass_Medic)
						{
							int iWeapon = GetPlayerWeaponSlot(client, 0);
							if (iWeapon > MaxClients)
							{
								char sWeaponClass[64];
								GetEdictClassname(iWeapon, sWeaponClass, sizeof(sWeaponClass));
								if (strcmp(sWeaponClass, "tf_weapon_crossbow") == 0)
								{
									int iClip = GetEntProp(iWeapon, Prop_Send, "m_iClip1");
									if (iClip > 0)
									{
										buttons |= IN_ATTACK;
										g_iPlayerLastButtons[client] = buttons;
										buttons &= ~IN_ATTACK2;
										bChanged = true;
										
										RequestFrame(Frame_ClientHealArrow, client);
										
										EmitSoundToAll(")weapons/crusaders_crossbow_shoot.wav", client, SNDCHAN_WEAPON, SNDLEVEL_MINIBIKE); //Fix client's predictions.
									}
								}
							}
						}
					}
				}
			}
			if (button == IN_ATTACK2)
			{
				if (!g_PlayerEliminated[client])
				{
					g_iPlayerLastButtons[client] = buttons;
					int iWeaponActive = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
					if (iWeaponActive > MaxClients && IsTauntWep(iWeaponActive))
					{
						buttons &= ~IN_ATTACK2; //Tough break update made players able to taunt with secondary attack. Block this feature.
						bChanged = true;
					}
				}
			}
			/*if (!g_PlayerEliminated[client] && button == IN_JUMP && g_PlayerSprintPoints[client] < 7)
			{
				g_iPlayerLastButtons[client] = buttons;
				buttons &= ~IN_JUMP;
				bChanged = true;
			}*/
		}
		else if ((g_iPlayerLastButtons[client] & button))
		{
			ClientOnButtonRelease(client, button);
		}
	}
	
	AFK_CheckTime(client);

	if (!bChanged) g_iPlayerLastButtons[client] = buttons;
	return (bChanged) ? Plugin_Changed : Plugin_Continue;
}

public void OnClientCookiesCached(int client)
{
	if (!g_Enabled) return;
	
	// Load our saved settings.
	char sCookie[64];
	GetClientCookie(client, g_Cookie, sCookie, sizeof(sCookie));
	
	g_iPlayerQueuePoints[client] = 0;
	
	g_PlayerPreferences[client].PlayerPreference_PvPAutoSpawn = false;
	g_PlayerPreferences[client].PlayerPreference_ShowHints = true;
	g_PlayerPreferences[client].PlayerPreference_MuteMode = 0;
	g_PlayerPreferences[client].PlayerPreference_FilmGrain = false;
	g_PlayerPreferences[client].PlayerPreference_EnableProxySelection = true;
	g_PlayerPreferences[client].PlayerPreference_FlashlightTemperature = 6;
	g_PlayerPreferences[client].PlayerPreference_GhostModeToggleState = 0;
	g_PlayerPreferences[client].PlayerPreference_GhostModeTeleportState = 0;
	g_PlayerPreferences[client].PlayerPreference_GroupOutline = true;
	g_PlayerPreferences[client].PlayerPreference_ProxyShowMessage = g_PlayerProxyAskConVar.BoolValue;
	g_PlayerPreferences[client].PlayerPreference_PvPSpawnProtection = true;
	g_PlayerPreferences[client].PlayerPreference_ViewBobbing = g_PlayerViewbobEnabledConVar.BoolValue;
	g_PlayerPreferences[client].PlayerPreference_LegacyHud = g_DefaultLegacyHudConVar.BoolValue;
	
	if (sCookie[0] != '\0')
	{
		char s2[15][32];
		int count = ExplodeString(sCookie, " ; ", s2, 15, 32);
		
		if (count > 0)
			g_iPlayerQueuePoints[client] = StringToInt(s2[0]);
		if (count > 1)
			g_PlayerPreferences[client].PlayerPreference_PvPAutoSpawn = view_as<bool>(StringToInt(s2[1]));
		if (count > 2)
			g_PlayerPreferences[client].PlayerPreference_ShowHints = view_as<bool>(StringToInt(s2[2]));
		if (count > 3)
			g_PlayerPreferences[client].PlayerPreference_MuteMode = StringToInt(s2[3]);
		if (count > 4)
			g_PlayerPreferences[client].PlayerPreference_FilmGrain = view_as<bool>(StringToInt(s2[4]));
		if (count > 5)
			g_PlayerPreferences[client].PlayerPreference_EnableProxySelection = view_as<bool>(StringToInt(s2[5]));
		if (count > 6)
			g_PlayerPreferences[client].PlayerPreference_FlashlightTemperature = StringToInt(s2[6]);
		if (count > 7)
			g_PlayerPreferences[client].PlayerPreference_PvPSpawnProtection = view_as<bool>(StringToInt(s2[7]));
		if (count > 8)
			g_PlayerPreferences[client].PlayerPreference_ProxyShowMessage = view_as<bool>(StringToInt(s2[8]));
		if (count > 9)
			g_PlayerPreferences[client].PlayerPreference_ViewBobbing = view_as<bool>(StringToInt(s2[9]));
		if (count > 10)
			g_PlayerPreferences[client].PlayerPreference_GhostModeToggleState = StringToInt(s2[10]);
		if (count > 11)
			g_PlayerPreferences[client].PlayerPreference_GroupOutline = view_as<bool>(StringToInt(s2[11]));
		if (count > 12)
			g_PlayerPreferences[client].PlayerPreference_GhostModeTeleportState = StringToInt(s2[12]);
		if (count > 13)
			g_PlayerPreferences[client].PlayerPreference_LegacyHud = view_as<bool>(StringToInt(s2[13]));
	}
}

public void OnClientPutInServer(int client)
{
	if (!g_Enabled) return;
	
	if (IsClientSourceTV(client))g_SourceTVUserID = GetClientUserId(client);
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("START OnClientPutInServer(%d)", client);
	#endif
	
	ClientSetPlayerGroup(client, -1);
	
	g_LastCommandTime[client] = GetEngineTime();
	
	g_PlayerEscaped[client] = false;
	g_PlayerEliminated[client] = true;
	g_bPlayerChoseTeam[client] = false;
	g_bPlayerPlayedSpecialRound[client] = true;
	g_bPlayerPlayedNewBossRound[client] = true;
	
	g_PlayerPreferences[client].PlayerPreference_PvPAutoSpawn = false;
	g_PlayerPreferences[client].PlayerPreference_ProjectedFlashlight = false;
	
	g_PlayerPageCount[client] = 0;
	g_PlayerDesiredFOV[client] = 90;
	
	SDKHook(client, SDKHook_PreThink, Hook_ClientPreThink);
	SDKHook(client, SDKHook_SetTransmit, Hook_ClientSetTransmit);
	SDKHook(client, SDKHook_TraceAttack, Hook_PvPPlayerTraceAttack);
	SDKHook(client, SDKHook_OnTakeDamage, Hook_ClientOnTakeDamage);
	
	SDKHook(client, SDKHook_WeaponEquipPost, Hook_ClientWeaponEquipPost);
	
	g_hSDKWantsLagCompensationOnEntity.HookEntity(Hook_Pre, client, Hook_ClientWantsLagCompensationOnEntity);
	
	g_hSDKShouldTransmit.HookEntity(Hook_Pre, client, Hook_EntityShouldTransmit);
	
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		if (!IsPlayerGroupActive(i)) continue;
		
		SetPlayerGroupInvitedPlayer(i, client, false);
		SetPlayerGroupInvitedPlayerCount(i, client, 0);
		SetPlayerGroupInvitedPlayerTime(i, client, 0.0);
	}
	
	ClientResetStatic(client);
	ClientResetSlenderStats(client);
	ClientResetCampingStats(client);
	ClientResetOverlay(client);
	ClientResetJumpScare(client);
	ClientUpdateListeningFlags(client);
	ClientUpdateMusicSystem(client);
	ClientChaseMusicReset(client);
	ClientChaseMusicSeeReset(client);
	ClientAlertMusicReset(client);
	ClientIdleMusicReset(client);
	Client20DollarsMusicReset(client);
	Client90sMusicReset(client);
	ClientMusicReset(client);
	ClientResetProxy(client);
	ClientResetHints(client);
	ClientResetScare(client);
	
	ClientResetDeathCam(client);
	ClientResetFlashlight(client);
	ClientDeactivateUltravision(client);
	ClientResetSprint(client);
	ClientResetBreathing(client);
	ClientResetBlink(client);
	ClientResetInteractiveGlow(client);
	ClientDisableConstantGlow(client);
	
	ClientSetScareBoostEndTime(client, -1.0);
	
	ClientStartProxyAvailableTimer(client);

	for (int npcIndex = 0; npcIndex < MAX_BOSSES; npcIndex++)
	{
		if (NPCGetUniqueID(npcIndex) == -1) continue;
		if (g_NpcChaseOnLookTarget[npcIndex] == null) continue;
		int foundClient = g_NpcChaseOnLookTarget[npcIndex].FindValue(client);
		if (foundClient != -1) g_NpcChaseOnLookTarget[npcIndex].Erase(foundClient);
	}
	
	if (!IsFakeClient(client))
	{
		// See if the player is using the projected flashlight.
		QueryClientConVar(client, "mat_supportflashlight", OnClientGetProjectedFlashlightSetting);
		
		// Get desired FOV.
		QueryClientConVar(client, "fov_desired", OnClientGetDesiredFOV);
	}
	
	PvP_OnClientPutInServer(client);
	
	#if defined DEBUG
	g_PlayerDebugFlags[client] = 0;
	
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("END OnClientPutInServer(%d)", client);
	#endif
}

public void OnClientGetProjectedFlashlightSetting(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (result != ConVarQuery_Okay)
	{
		LogError("Warning: Player %N failed to query for ConVar mat_supportflashlight", client);
		return;
	}
	
	if (StringToInt(cvarValue))
	{
		char sAuth[64];
		GetClientAuthId(client, AuthId_Engine, sAuth, sizeof(sAuth));
		
		g_PlayerPreferences[client].PlayerPreference_ProjectedFlashlight = true;
		LogSF2Message("Player %N (%s) has mat_supportflashlight enabled, projected flashlight will be used", client, sAuth);
	}
}

public void OnClientGetDesiredFOV(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (!IsValidClient(client)) return;
	
	g_PlayerDesiredFOV[client] = StringToInt(cvarValue);
}

public void OnClientDisconnect(int client)
{
	if (!g_Enabled) return;
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("START OnClientDisconnect(%d)", client);
	#endif
	
	Handle message = StartMessageAll("PlayerTauntSoundLoopEnd", USERMSG_RELIABLE);
	BfWriteByte(message, client);
	delete message;
	EndMessage();
	
	g_SeeUpdateMenu[client] = false;
	g_PlayerEscaped[client] = false;
	g_PlayerNoPoints[client] = false;
	g_AdminNoPoints[client] = false;
	g_AdminAllTalk[client] = false;
	g_PlayerIn1UpCondition[client] = false;
	g_PlayerDied1Up[client] = false;
	g_bPlayerFullyDied1Up[client] = false;

	// Save and reset settings for the next client.
	ClientSaveCookies(client);
	ClientSetPlayerGroup(client, -1);
	
	// Reset variables.
	g_PlayerPreferences[client].PlayerPreference_ShowHints = true;
	g_PlayerPreferences[client].PlayerPreference_MuteMode = 0;
	g_PlayerPreferences[client].PlayerPreference_FilmGrain = false;
	g_PlayerPreferences[client].PlayerPreference_EnableProxySelection = true;
	g_PlayerPreferences[client].PlayerPreference_ProjectedFlashlight = false;
	g_PlayerPreferences[client].PlayerPreference_FlashlightTemperature = 6;
	g_PlayerPreferences[client].PlayerPreference_GhostModeToggleState = 0;
	g_PlayerPreferences[client].PlayerPreference_GhostModeTeleportState = 0;
	g_PlayerPreferences[client].PlayerPreference_GroupOutline = true;
	g_PlayerPreferences[client].PlayerPreference_ProxyShowMessage = g_PlayerProxyAskConVar.BoolValue;
	g_PlayerPreferences[client].PlayerPreference_PvPSpawnProtection = true;
	g_PlayerPreferences[client].PlayerPreference_ViewBobbing = g_PlayerViewbobEnabledConVar.BoolValue;
	g_PlayerPreferences[client].PlayerPreference_LegacyHud = g_DefaultLegacyHudConVar.BoolValue;
	
	// Reset any client functions that may be still active.
	ClientResetOverlay(client);
	ClientResetFlashlight(client);
	ClientDeactivateUltravision(client);
	ClientSetGhostModeState(client, false);
	ClientResetInteractiveGlow(client);
	ClientDisableConstantGlow(client);
	
	ClientStopProxyForce(client);
	
	Network_ResetClient(client);
	
	if (SF_IsBoxingMap() && IsRoundInEscapeObjective())
	{
		CreateTimer(0.2, Timer_CheckAlivePlayers, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	if (!IsRoundInWarmup())
	{
		if (g_bPlayerPlaying[client] && !g_PlayerEliminated[client])
		{
			if (!IsRoundPlaying())
			{
				// Force the next player in queue to take my place, if any.
				ForceInNextPlayersInQueue(1, true);
			}
			else
			{
				if (!IsRoundEnding())
				{
					CreateTimer(0.2, Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
	
	g_PlayerEliminated[client] = true;
	// Reset queue points global variable.
	g_iPlayerQueuePoints[client] = 0;
	
	PvP_OnClientDisconnect(client);
	AFK_SetTime(client, false);
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("END OnClientDisconnect(%d)", client);
	#endif
}

public void OnClientDisconnect_Post(int client)
{
	g_iPlayerLastButtons[client] = 0;
}

public void TF2_OnWaitingForPlayersStart()
{
	g_bRoundWaitingForPlayers = true;
}

public void TF2_OnWaitingForPlayersEnd()
{
	g_bRoundWaitingForPlayers = false;
}

SF2RoundState GetRoundState()
{
	return g_iRoundState;
}

void SetRoundTimerPaused(bool bPaused)
{
	g_bRoundTimerPaused = bPaused;
}

void SetRoundTime(int iCurrentTime)
{
	int iOldRoundTime = g_RoundTime;
	if (iCurrentTime == iOldRoundTime)
		return;
	
	g_RoundTime = iCurrentTime;
	
	switch (GetRoundState())
	{
		case SF2RoundState_Escape:
		{
			if (SF_IsSurvivalMap() && iCurrentTime <= g_iTimeEscape && iOldRoundTime > g_iTimeEscape && g_GamerulesEntity.IsValid())
			{
				g_GamerulesEntity.FireOutput("OnSurvivalComplete");
			}
		}
	}
}

void SetRoundState(SF2RoundState iRoundState)
{
	if (g_iRoundState == iRoundState) return;
	
	PrintToServer("SetRoundState(%d)", iRoundState);
	
	SF2RoundState iOldRoundState = GetRoundState();
	g_iRoundState = iRoundState;
	
	//Tutorial_OnRoundStateChange(iOldRoundState, g_iRoundState);
	
	// Cleanup from old roundstate if needed.
	switch (iOldRoundState)
	{
		case SF2RoundState_Waiting:
		{
		}
		case SF2RoundState_Intro:
		{
			g_hRoundIntroTimer = null;
			if (!IsInfiniteFlashlightEnabled())g_NightvisionType = GetRandomInt(0, 2);
			else g_NightvisionType = 1;

			// Enable movement on players.
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || g_PlayerEliminated[i]) continue;
				SetEntityFlags(i, GetEntityFlags(i) & ~FL_FROZEN);
			}
			
			// Fade in.
			float flFadeTime = g_flRoundIntroFadeDuration;
			int iFadeFlags = SF_FADE_IN | FFADE_PURGE;
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || g_PlayerEliminated[i]) continue;
				UTIL_ScreenFade(i, FixedUnsigned16(flFadeTime, 1 << 12), 0, iFadeFlags, g_iRoundIntroFadeColor[0], g_iRoundIntroFadeColor[1], g_iRoundIntroFadeColor[2], g_iRoundIntroFadeColor[3]);
			}
		}
		case SF2RoundState_Grace:
		{
			g_hRoundGraceTimer = null;

			for (int client = 1; client <= MaxClients; client++)
			{
				if (!IsClientParticipating(client))
				{
					g_PlayerEliminated[client] = true;
				}

				if (IsValidClient(client))
				{
					TF2Attrib_RemoveByDefIndex(client, 10);

					if (IsClientParticipating(client) && GetClientTeam(client) == TFTeam_Blue && g_PlayerPreferences[client].PlayerPreference_GhostModeToggleState == 1)
					{
						CreateTimer(0.25, Timer_ToggleGhostModeCommand, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}

			if (g_RestartSessionEnabled)
			{
				ArrayList hSpawnPoint = new ArrayList();
				#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been created for hSpawnPoint in SetRoundState(SF2RoundState_Grace).", hSpawnPoint);
				#endif
				float flTeleportPos[3];
				int ent = -1, iSpawnTeam = 0;
				while ((ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1)
				{
					iSpawnTeam = GetEntProp(ent, Prop_Data, "m_iInitialTeamNum");
					if (iSpawnTeam == TFTeam_Red)
					{
						hSpawnPoint.Push(ent);
					}
					
				}
				ent = -1;
				if (hSpawnPoint.Length > 0)
				{
					for (int npcIndex = 0; npcIndex < MAX_BOSSES; npcIndex++)
					{
						ent = hSpawnPoint.Get(GetRandomInt(0, hSpawnPoint.Length - 1));
						
						if (IsValidEntity(ent))
						{
							GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flTeleportPos);
							SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(npcIndex);
							if (!Npc.IsValid()) continue;
							SpawnSlender(Npc, flTeleportPos);
						}
					}
				}
				delete hSpawnPoint;
				#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been deleted for hSpawnPoint in SetRoundState(SF2RoundState_Grace).", hSpawnPoint);
				#endif
			}

			CPrintToChatAll("{dodgerblue}%t", "SF2 Grace Period End");
		}
		case SF2RoundState_Active:
		{
			g_hRoundGraceTimer = null;
			g_hRoundTimer = null;
			g_PlayersAreCritted = false;
			g_PlayersAreMiniCritted = false;
			g_RoundTimeMessage = 0.0;
			bool bNightVision = (g_NightvisionEnabledConVar.BoolValue || SF_SpecialRound(SPECIALROUND_NIGHTVISION));
			if (bNightVision)
			{
				switch (g_NightvisionType)
				{
					case 2:
					{
						g_hBlueNightvisionOutlineTimer = CreateTimer(10.0, Timer_BlueNightvisionOutline, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
					}
					default:
					{
						g_hBlueNightvisionOutlineTimer = null;
					}
				}
			}
		}
		case SF2RoundState_Escape:
		{
			g_hRoundTimer = null;
		}
		case SF2RoundState_Outro:
		{
		}
	}
	
	switch (g_iRoundState)
	{
		case SF2RoundState_Waiting:
		{
		}
		case SF2RoundState_Intro:
		{
			g_hRoundIntroTimer = null;
			g_RoundTimeMessage = 0.0;
			g_InProxySurvivalRageMode = false;
			g_RenevantWaveTimer = null;
			g_RenevantMultiEffect = false;
			g_RenevantBeaconEffect = false;
			g_Renevant90sEffect = false;
			g_RenevantMarkForDeath = false;
			if (g_RestartSessionConVar.BoolValue)
			{
				g_RestartSessionEnabled = false;
				g_RestartSessionConVar.SetBool(false);
			}
			StartIntroTextSequence();
			
			// Gather data on the intro parameters set by the map.
			float flHoldTime = g_flRoundIntroFadeHoldTime;
			g_hRoundIntroTimer = CreateTimer(flHoldTime, Timer_ActivateRoundFromIntro, _, TIMER_FLAG_NO_MAPCHANGE);
			
			// Trigger any intro logic entities, if any.
			int ent = -1;
			while ((ent = FindEntityByClassname(ent, "logic_relay")) != -1)
			{
				char sName[64];
				GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
				if (strcmp(sName, "sf2_intro_relay", false) == 0)
				{
					AcceptEntityInput(ent, "Trigger");
					break;
				}
			}
		}
		case SF2RoundState_Grace:
		{
			// Start the grace period timer.
			g_hRoundGraceTimer = CreateTimer(g_GraceTimeConVar.FloatValue, Timer_RoundGrace, _, TIMER_FLAG_NO_MAPCHANGE);
			
			CreateTimer(2.0, Timer_RoundStart, _, TIMER_FLAG_NO_MAPCHANGE);
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || g_PlayerEliminated[i]) continue;

				TF2Attrib_SetByDefIndex(i, 10, 7.0);
			}
		}
		case SF2RoundState_Active:
		{
			if (SF_IsRenevantMap()) NPCRemoveAll();
			// Initialize the main round timer.
			if (g_RoundTimeLimit > 0)
			{
				// Set round time.
				SetRoundTime(g_RoundTimeLimit);
				g_hRoundTimer = CreateTimer(1.0, Timer_RoundTime, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				// Infinite round time.
				g_hRoundTimer = null;
			}
		}
		case SF2RoundState_Escape:
		{
			// Initialize the escape timer, if needed.
			if (g_RoundEscapeTimeLimit > 0)
			{
				SetRoundTime(g_RoundEscapeTimeLimit);
				g_hRoundTimer = CreateTimer(1.0, Timer_RoundTimeEscape, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_hRoundTimer = null;
			}
			
			char sName[32];
			int ent = -1;
			while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
			{
				GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
				if (!SF_IsBoxingMap())
				{
					if (strcmp(sName, "sf2_logic_escape", false) == 0)
					{
						AcceptEntityInput(ent, "FireUser1");
						break;
					}
				}
				else
				{
					if (strcmp(sName, "sf2_logic_escape", false) == 0)
					{
						AcceptEntityInput(ent, "FireUser1");
						break;
					}
				}
			}
			if (SF_IsBoxingMap())
			{
				g_DifficultyConVar.IntValue = Difficulty_Normal;
				CPrintToChatAll("%t", "SF2 Boxing Initiate");
				CreateTimer(0.2, Timer_CheckAlivePlayers, _, TIMER_FLAG_NO_MAPCHANGE);
				
				for (int iBoss = 0; iBoss < MAX_BOSSES; iBoss++)
				{
					SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(iBoss);
					if (!Npc.IsValid()) continue;
					if (NPCChaserIsBoxingBoss(Npc.Index)) g_SlenderBoxingBossCount += 1;
				}
			}
			else if (SF_IsRenevantMap())
			{
				Renevant_SetWave(1, true);
			}
		}
		case SF2RoundState_Outro:
		{
			if (!g_bRoundHasEscapeObjective)
			{
				// Teleport winning players to the escape point.
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i)) continue;
					
					if (!g_PlayerEliminated[i])
					{
						TeleportClientToEscapePoint(i);
					}
				}
			}
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i)) continue;
				
				if (IsClientInGhostMode(i))
				{
					// Take the player out of ghost mode.
					ClientSetGhostModeState(i, false);
					TF2_RespawnPlayer(i);
				}
				else if (g_PlayerProxy[i])
				{
					TF2_RespawnPlayer(i);
				}
				
				if (!g_PlayerEliminated[i])
				{
					// Give them back all their weapons so they can beat the crap out of the other team.
					TF2_RegeneratePlayer(i);
				}
				
				ClientUpdateListeningFlags(i);
			}
		}
	}
	
	SF2MapEntity_OnRoundStateChanged(iRoundState, iOldRoundState);
	
	Call_StartForward(g_OnRoundStateChangeFwd);
	Call_PushCell(iOldRoundState);
	Call_PushCell(g_iRoundState);
	Call_Finish();
}

bool IsRoundPlaying()
{
	return (GetRoundState() == SF2RoundState_Active || GetRoundState() == SF2RoundState_Escape);
}

bool IsRoundInEscapeObjective()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Escape);
}

bool IsRoundInWarmup()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Waiting);
}

bool IsRoundInIntro()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Intro);
}

bool IsRoundEnding()
{
	return view_as<bool>(GetRoundState() == SF2RoundState_Outro);
}

bool IsInfiniteBlinkEnabled()
{
	return view_as<bool>(g_bRoundInfiniteBlink || (g_PlayerInfiniteBlinkOverrideConVar.IntValue == 1));
}

bool IsInfiniteSprintEnabled()
{
	return view_as<bool>(g_IsRoundInfiniteSprint || (g_PlayerInfiniteSprintOverrideConVar.IntValue == 1));
}

stock bool IsClientParticipating(int client)
{
	if (!IsValidClient(client)) return false;
	
	if (view_as<bool>(GetEntProp(client, Prop_Send, "m_bIsCoaching")))
	{
		// Who would coach in this game?
		return false;
	}
	
	int iTeam = GetClientTeam(client);
	
	switch (iTeam)
	{
		case TFTeam_Unassigned, TFTeam_Spectator: return false;
	}
	
	if (view_as<int>(TF2_GetPlayerClass(client)) == 0)
	{
		// Player hasn't chosen a class? What.
		return false;
	}
	
	return true;
}

ArrayList GetQueueList()
{
	ArrayList hArray = new ArrayList(3);
	#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been created for hArray in GetQueueList.", hArray);
	#endif
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientParticipating(i)) continue;
		if (IsPlayerGroupActive(ClientGetPlayerGroup(i))) continue;
		
		int index = hArray.Push(i);
		hArray.Set(index, g_iPlayerQueuePoints[i], 1);
		hArray.Set(index, false, 2);
	}
	
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		if (!IsPlayerGroupActive(i)) continue;
		int index = hArray.Push(i);
		hArray.Set(index, GetPlayerGroupQueuePoints(i), 1);
		hArray.Set(index, true, 2);
	}
	
	if (hArray.Length > 0) hArray.SortCustom(SortQueueList);
	return hArray;
}

stock int GetOppositeTeam(int iTeam) {
	return iTeam == 2 ? 3 : 2;
}

stock int GetOppositeTeamOf(int client) {
	int iTeam = GetClientTeam(client);
	return GetOppositeTeam(iTeam);
}

void SetClientPlayState(int client, bool bState, bool bEnablePlay=true)
{
	Handle message = StartMessageAll("PlayerTauntSoundLoopEnd", USERMSG_RELIABLE);
	BfWriteByte(message, client);
	delete message;
	EndMessage();

	if (bState)
	{
		if (!g_PlayerEliminated[client]) return;
		if (g_PlayerProxy[client]) return;
		
		g_PlayerCalledForNightmare[client] = false;
		g_PlayerEliminated[client] = false;
		g_bPlayerPlaying[client] = bEnablePlay;
		g_hPlayerSwitchBlueTimer[client] = null;
		
		ClientSetGhostModeState(client, false);
		
		PvP_SetPlayerPvPState(client, false, false, false);
		
		if (g_IsSpecialRound) 
		{
			SetClientPlaySpecialRoundState(client, true);
		}
		
		if (g_bNewBossRound) 
		{
			SetClientPlayNewBossRoundState(client, true);
		}
		
		if (TF2_GetPlayerClass(client) == view_as<TFClassType>(0))
		{
			// Player hasn't chosen a class for some reason. Choose one for him.
			TF2_SetPlayerClass(client, view_as<TFClassType>(GetRandomInt(1, 9)), true, true);
		}
		
		ChangeClientTeamNoSuicide(client, TFTeam_Red);
	}
	else
	{
		if (g_PlayerEliminated[client]) return;
		
		g_PlayerEliminated[client] = true;
		g_bPlayerPlaying[client] = false;
		
		ChangeClientTeamNoSuicide(client, TFTeam_Blue);
	}

}
/*
bool DidClientPlayNewBossRound(int client)
{
	return g_bPlayerPlayedNewBossRound[client];
}
*/
void SetClientPlayNewBossRoundState(int client, bool bState)
{
	g_bPlayerPlayedNewBossRound[client] = bState;
}
/*
bool DidClientPlaySpecialRound(int client)
{
	return g_bPlayerPlayedNewBossRound[client];
}
*/
void SetClientPlaySpecialRoundState(int client, bool bState)
{
	g_bPlayerPlayedSpecialRound[client] = bState;
}

void TeleportClientToEscapePoint(int client)
{
	if (!IsClientInGame(client)) return;
	
	ArrayList hSpawnPoints = new ArrayList();
	
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "sf2_info_player_escapespawn")) != -1)
	{
		SF2PlayerEscapeSpawnEntity spawnPoint = SF2PlayerEscapeSpawnEntity(ent);
		if (!spawnPoint.IsValid() || !spawnPoint.Enabled)
			continue;
		
		hSpawnPoints.Push(ent);
	}
	
	if (hSpawnPoints.Length > 0)
		ent = hSpawnPoints.Get(GetRandomInt(0, hSpawnPoints.Length - 1));
	else
		ent = EntRefToEntIndex(g_iRoundEscapePointEntity);
	
	delete hSpawnPoints;
	
	if (ent && IsValidEntity(ent))
	{
		SF2PlayerEscapeSpawnEntity spawnPoint = SF2PlayerEscapeSpawnEntity(ent);
		
		float flPos[3], flAng[3];
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flPos);
		GetEntPropVector(ent, Prop_Data, "m_angAbsRotation", flAng);
		
		TeleportEntity(client, flPos, flAng, view_as<float>( { 0.0, 0.0, 0.0 } ));
		
		if (spawnPoint.IsValid())
		{
			spawnPoint.FireOutput("OnSpawn", client);
		}
		else
		{
			AcceptEntityInput(ent, "FireUser1", client);
		}
	}
}

void ForceInNextPlayersInQueue(int iAmount, bool bShowMessage = false)
{
	// Grab the next person in line, or the next group in line if space allows.
	int iAmountLeft = iAmount;
	ArrayList hPlayers = new ArrayList();
	ArrayList hArray = GetQueueList();

	#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been created for hPlayers in ForceInNextPlayersInQueue.", hPlayers);
	#endif
	
	for (int i = 0, iSize = hArray.Length; i < iSize && iAmountLeft > 0; i++)
	{
		if (!hArray.Get(i, 2))
		{
			int client = hArray.Get(i);
			if (g_bPlayerPlaying[client] || !g_PlayerEliminated[client] || !IsClientParticipating(client) || g_AdminNoPoints[client]) continue;
			
			hPlayers.Push(client);
			iAmountLeft -= 1;
		}
		else
		{
			int groupIndex = hArray.Get(i);
			if (!IsPlayerGroupActive(groupIndex)) continue;
			
			int iMemberCount = GetPlayerGroupMemberCount(groupIndex);
			if (iMemberCount <= iAmountLeft)
			{
				for (int client = 1; client <= MaxClients; client++)
				{
					if (!IsValidClient(client) || g_bPlayerPlaying[client] || !g_PlayerEliminated[client] || !IsClientParticipating(client)) continue;
					if (ClientGetPlayerGroup(client) == groupIndex)
					{
						hPlayers.Push(client);
					}
				}
				
				SetPlayerGroupPlaying(groupIndex, true);
				
				iAmountLeft -= iMemberCount;
			}
		}
	}
	
	delete hArray;
	#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been deleted for hArray in ForceInNextPlayersInQueue.", hArray);
	#endif
	
	for (int i = 0, iSize = hPlayers.Length; i < iSize; i++)
	{
		int client = hPlayers.Get(i);
		ClientSetQueuePoints(client, 0);
		if (IsClientInGhostMode(client))
		{
			ClientSetGhostModeState(client, false);
			TF2_RespawnPlayer(client);
			TF2_RemoveCondition(client, TFCond_StealthedUserBuffFade);
			g_LastCommandTime[client] = GetEngineTime()+0.5;
			CreateTimer(0.25, Timer_ForcePlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		else SetClientPlayState(client, true);
		
		if (bShowMessage) CPrintToChat(client, "%T", "SF2 Force Play", client);
	}
	
	delete hPlayers;
	#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been deleted for hPlayers in ForceInNextPlayersInQueue.", hPlayers);
	#endif
}

public int SortQueueList(int index1, int index2, Handle array, Handle hndl)
{
	ArrayList aArray = view_as<ArrayList>(array);
	
	bool bDisabled = g_PlayerNoPoints[aArray.Get(index1, 0)];
	if (bDisabled != g_PlayerNoPoints[aArray.Get(index2, 0)]) return bDisabled ? 1 : -1;

	int iQueuePoints1 = aArray.Get(index1, 1);
	int iQueuePoints2 = aArray.Get(index2, 1);
	
	if (iQueuePoints1 > iQueuePoints2) return -1;
	else if (iQueuePoints1 == iQueuePoints2) return 0;
	return 1;
}

//	==========================================================
//	GENERIC PAGE/BOSS HOOKS AND FUNCTIONS
//	==========================================================

public Action Hook_SlenderObjectSetTransmit(int ent, int other)
{
	if (!g_Enabled) return Plugin_Continue;
	
	if (!IsPlayerAlive(other) || IsClientInDeathCam(other))
	{
		if (!IsValidEdict(GetEntPropEnt(other, Prop_Send, "m_hObserverTarget"))) return Plugin_Handled;
	}
	if (IsClientInGhostMode(other) || g_PlayerProxy[other]) return Plugin_Handled;
	if (IsValidClient(other))
	{
		if (ClientGetDistanceFromEntity(other, ent) >= SquareFloat(320.0) || GetClientTeam(other) == TFTeam_Spectator)
			return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action Hook_SlenderObjectSetTransmitEx(int ent, int other)
{
	if (!g_Enabled) return Plugin_Continue;
	
	if (!IsPlayerAlive(other) || IsClientInDeathCam(other))
	{
		if (!IsValidEdict(GetEntPropEnt(other, Prop_Send, "m_hObserverTarget"))) return Plugin_Handled;
	}
	if (IsClientInGhostMode(other) || g_PlayerProxy[other]) return Plugin_Handled;
	if (IsValidClient(other))
	{
		if (ClientGetDistanceFromEntity(other, ent) <= SquareFloat(320.0) || GetClientTeam(other) == TFTeam_Spectator)
			return Plugin_Handled;
	}
	
	return Plugin_Continue;
}


void SlenderOnClientStressUpdate(int client)
{
	int difficulty = g_DifficultyConVar.IntValue;

	float flStress = g_PlayerStressAmount[client];
	
	char profile[SF2_MAX_PROFILE_NAME_LENGTH];
	
	for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
	{
		if (NPCGetUniqueID(bossIndex) == -1) continue;
		
		int iBossFlags = NPCGetFlags(bossIndex);
		if (iBossFlags & SFF_MARKEDASFAKE || 
			iBossFlags & SFF_NOTELEPORT)
		{
			continue;
		}
		
		NPCGetProfile(bossIndex, profile, sizeof(profile));
		
		int iTeleportTarget = EntRefToEntIndex(g_SlenderTeleportTarget[bossIndex]);
		if (iTeleportTarget && iTeleportTarget != INVALID_ENT_REFERENCE && !g_PlayerIsExitCamping[iTeleportTarget])
		{
			if (g_PlayerEliminated[iTeleportTarget] || 
				DidClientEscape(iTeleportTarget) || 
				(!SF_IsRenevantMap() && !SF_IsSurvivalMap() && !g_bSlenderTeleportIgnoreChases[bossIndex] && flStress >= g_SlenderTeleportMaxTargetStress[bossIndex]) || 
				GetGameTime() >= g_SlenderTeleportMaxTargetTime[bossIndex])
			{
				// Queue for a new target and mark the old target in the rest period.
				float flRestPeriod = NPCGetTeleportRestPeriod(bossIndex, difficulty);
				flRestPeriod = (flRestPeriod * GetRandomFloat(0.92, 1.08)) / (g_RoundDifficultyModifier);
				
				g_SlenderTeleportTarget[bossIndex] = INVALID_ENT_REFERENCE;
				g_SlenderTeleportPlayersRestTime[bossIndex][iTeleportTarget] = GetGameTime() + flRestPeriod;
				g_SlenderTeleportMaxTargetStress[bossIndex] = 9999.0;
				g_SlenderTeleportMaxTargetTime[bossIndex] = -1.0;
				g_SlenderTeleportTargetTime[bossIndex] = -1.0;
				
				#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: lost target, putting at rest period", bossIndex);
				#endif
			}
		}
		else if (IsRoundPlaying())
		{
			int iPreferredTeleportTarget = INVALID_ENT_REFERENCE;
			
			float flTargetStressMin = NPCGetTeleportStressMin(bossIndex, difficulty);
			float flTargetStressMax = NPCGetTeleportStressMax(bossIndex, difficulty);
			
			float flTargetStress = flTargetStressMax - ((flTargetStressMax - flTargetStressMin) / (g_RoundDifficultyModifier));
			
			float flPreferredTeleportTargetStress = flTargetStress;
			
			int iRaidClient;
			if (NPCAreAvailablePlayersAlive())
			{
				do
				{
					iRaidClient = GetRandomInt(1, MaxClients);
				}
				while (!IsClientInGame(iRaidClient) || 
					!IsPlayerAlive(iRaidClient) || 
					g_PlayerEliminated[iRaidClient] || 
					IsClientInGhostMode(iRaidClient) || 
					DidClientEscape(iRaidClient));
			}
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (g_PlayerIsExitCamping[i])
				{
					if (IsValidClient(iTeleportTarget) && !g_PlayerIsExitCamping[iTeleportTarget])
					{
						iPreferredTeleportTarget = i;
						break;
					}
				}
				if (g_PlayerStressAmount[i] < flPreferredTeleportTargetStress || g_RestartSessionEnabled)
				{
					if (g_SlenderTeleportPlayersRestTime[bossIndex][i] <= GetGameTime())
					{
						iPreferredTeleportTarget = i;
						flPreferredTeleportTargetStress = g_PlayerStressAmount[i];
					}
				}
				if (i == iRaidClient && IsValidClient(iRaidClient))
				{
					g_SlenderProxyTarget[bossIndex] = EntIndexToEntRef(iRaidClient);
					iPreferredTeleportTarget = iRaidClient;
				}
			}
			
			if (IsValidClient(iPreferredTeleportTarget))
			{
				// Set our preferred target to the new guy.
				float flTargetDuration = NPCGetTeleportPersistencyPeriod(bossIndex, difficulty);
				float flDeviation = GetRandomFloat(0.92, 1.08);
				flTargetDuration = Pow(flDeviation * flTargetDuration, ((g_RoundDifficultyModifier * (NPCGetAnger(bossIndex) - 1.0)) / 2.0)) + ((flDeviation * flTargetDuration) - 1.0);
				
				g_SlenderTeleportTarget[bossIndex] = EntIndexToEntRef(iPreferredTeleportTarget);
				g_SlenderTeleportPlayersRestTime[bossIndex][iPreferredTeleportTarget] = -1.0;
				g_SlenderTeleportMaxTargetTime[bossIndex] = GetGameTime() + flTargetDuration;
				g_SlenderTeleportTargetTime[bossIndex] = GetGameTime();
				g_SlenderTeleportMaxTargetStress[bossIndex] = flTargetStress;
				
				iTeleportTarget = iPreferredTeleportTarget;
				
				#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_BOSS_TELEPORTATION, 0, "Teleport for boss %d: got new target %N", bossIndex, iPreferredTeleportTarget);
				#endif
			}
		}
	}
}

static int GetPageMusicRanges()
{
	g_PageMusicRanges.Clear();
	
	char sName[64];
	
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "ambient_generic")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		
		if (sName[0] != '\0' && !StrContains(sName, "sf2_page_music_", false))
		{
			ReplaceString(sName, sizeof(sName), "sf2_page_music_", "", false);
			
			char sPageRanges[2][32];
			ExplodeString(sName, "-", sPageRanges, 2, 32);
			
			int iIndex = g_PageMusicRanges.Push(EntIndexToEntRef(ent));
			if (iIndex != -1)
			{
				int iMin = StringToInt(sPageRanges[0]);
				int iMax = StringToInt(sPageRanges[1]);
				
				#if defined DEBUG
				DebugMessage("Page range found: entity %d, iMin = %d, iMax = %d", ent, iMin, iMax);
				#endif
				g_PageMusicRanges.Set(iIndex, iMin, 1);
				g_PageMusicRanges.Set(iIndex, iMax, 2);
			}
		}
	}
	
	while ((ent = FindEntityByClassname(ent, "sf2_info_page_music")) != -1)
	{
		SF2PageMusicEntity pageMusic = SF2PageMusicEntity(ent);
		if (!pageMusic.IsValid())
			continue;
		
		pageMusic.InsertRanges(g_PageMusicRanges);
	}
	
	// precache
	if (g_PageMusicRanges.Length > 0)
	{
		char sPath[PLATFORM_MAX_PATH];
		
		for (int i = 0; i < g_PageMusicRanges.Length; i++)
		{
			ent = EntRefToEntIndex(g_PageMusicRanges.Get(i));
			if (!ent || ent == INVALID_ENT_REFERENCE) continue;
			
			SF2PageMusicEntity pageMusic = SF2PageMusicEntity(ent);
			if (pageMusic.IsValid())
			{
				// Don't do anything; entity already precached its own music.
			}
			else
			{
				GetEntPropString(ent, Prop_Data, "m_iszSound", sPath, sizeof(sPath));
				if (sPath[0] != '\0')
					PrecacheSound(sPath);
			}
		}
	}
	
	LogSF2Message("Loaded page music ranges successfully!");
}
void SetPageCount(int iNum)
{
	if (iNum > g_PageMax)iNum = g_PageMax;
	
	int iOldPageCount = g_PageCount;
	g_PageCount = iNum;
	int difficulty = g_DifficultyConVar.IntValue;
	if (g_PageCount != iOldPageCount)
	{
		if (g_PageCount > iOldPageCount)
		{
			if (g_hRoundGraceTimer != null)
			{
				TriggerTimer(g_hRoundGraceTimer);
			}
			
			if (g_RoundTime < g_RoundTimeLimit)
			{
				// Add round time.
				int iRoundTime = g_RoundTime;
				
				if (!SF_SpecialRound(SPECIALROUND_NOPAGEBONUS))
					iRoundTime += g_RoundTimeGainFromPage;
				
				if (iRoundTime > g_RoundTimeLimit)iRoundTime = g_RoundTimeLimit;
				
				SetRoundTime(iRoundTime);
			}
			
			if (SF_SpecialRound(SPECIALROUND_DISTORTION))
			{
				ArrayList hClientSwap = new ArrayList();
				for (int client = 0; client < MAX_BOSSES; client++)
				{
					if (!IsValidClient(client)) continue;
					if (!IsPlayerAlive(client)) continue;
					if (g_PlayerEliminated[client]) continue;
					if (DidClientEscape(client)) continue;
					if (IsClientInDeathCam(client)) continue;
					hClientSwap.Push(client);
				}
				
				int iSize = hClientSwap.Length;
				if (iSize > 1)
				{
					int client, iClient2;
					float flPos[3], flPos2[3], flAng[3], flAng2[3], flVel[3], flVel2[3];
					hClientSwap.Sort(Sort_Random, Sort_Integer);
					for (int iArray = 0; iArray < (iSize / 2); iArray++)
					{
						client = hClientSwap.Get(iArray);
						GetClientAbsOrigin(client, flPos);
						GetClientEyeAngles(client, flAng);
						GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", flVel);
						
						iClient2 = hClientSwap.Get((iSize - 1) - iArray);
						GetClientAbsOrigin(iClient2, flPos2);
						GetClientEyeAngles(iClient2, flAng2);
						GetEntPropVector(iClient2, Prop_Data, "m_vecAbsVelocity", flVel2);
						
						TeleportEntity(client, flPos2, flAng2, flVel2);
						if (IsSpaceOccupiedIgnorePlayers(flPos2, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS, client))
						{
							Player_FindFreePosition2(client, flPos2, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS);
						}
						
						TeleportEntity(iClient2, flPos, flAng, flVel);
						if (IsSpaceOccupiedIgnorePlayers(flPos, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS, iClient2))
						{
							Player_FindFreePosition2(iClient2, flPos, HULL_TF2PLAYER_MINS, HULL_TF2PLAYER_MAXS);
						}
					}
				}
				delete hClientSwap;
			}
			
			if (SF_SpecialRound(SPECIALROUND_CLASSSCRAMBLE))
			{
				for (int client = 1; client <= MaxClients; client++)
				{
					if (!IsValidClient(client)) continue;
					if (!IsPlayerAlive(client)) continue;
					if (g_PlayerEliminated[client]) continue;
					if (DidClientEscape(client)) continue;
					
					TFClassType newClass;
					switch (g_PlayerRandomClassNumber[client])
					{
						case 1: newClass = TFClass_Scout;
						case 2: newClass = TFClass_Soldier;
						case 3: newClass = TFClass_Pyro;
						case 4: newClass = TFClass_DemoMan;
						case 5: newClass = TFClass_Heavy;
						case 6: newClass = TFClass_Engineer;
						case 7: newClass = TFClass_Medic;
						case 8: newClass = TFClass_Sniper;
						case 9: newClass = TFClass_Spy;
					}
					
					TF2_SetPlayerClass(client, newClass);
					
					CreateTimer(0.1, Timer_ClassScramblePlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.25, Timer_ClassScramblePlayer2, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
					
					// Regenerate player but keep health the same.
					int iHealth = GetEntProp(client, Prop_Send, "m_iHealth");
					TF2_RegeneratePlayer(client);
					SetEntProp(client, Prop_Data, "m_iHealth", iHealth);
					SetEntProp(client, Prop_Send, "m_iHealth", iHealth);
				}
			}
			
			// Increase anger on selected bosses.
			for (int i = 0; i < MAX_BOSSES; i++)
			{
				if (NPCGetUniqueID(i) == -1) continue;
				
				float flPageDiff = NPCGetAngerAddOnPageGrabTimeDiff(i);
				if (flPageDiff >= 0.0)
				{
					int iDiff = g_PageCount - iOldPageCount;
					if ((GetGameTime() - g_PageFoundLastTime) < flPageDiff)
					{
						NPCAddAnger(i, NPCGetAngerAddOnPageGrab(i) * float(iDiff));
					}
				}
			}
			
			if (SF_IsSlaughterRunMap())
			{
				if (g_PageCount == 1) //The first collectible for maps like Enclosed
				{
					int iBosses = 0;
					float[] flTimes = new float[MAX_BOSSES];
					float flAverageTime = 0.0;
					for (int npcIndex = 0; npcIndex < MAX_BOSSES; npcIndex++)
					{
						if (NPCGetUniqueID(npcIndex) == -1) continue;
						
						float flOriginalSpeed, flSpeed, flTimerCheck;
						flOriginalSpeed = NPCGetSpeed(npcIndex, difficulty) + NPCGetAddSpeed(npcIndex);
						if (flOriginalSpeed < 600.0) flOriginalSpeed = 600.0;
						if (g_RoundDifficultyModifier > 1.0)
						{
							flSpeed = flOriginalSpeed + ((flOriginalSpeed * g_RoundDifficultyModifier) / 15) + (NPCGetAnger(npcIndex) * g_RoundDifficultyModifier);
						}
						else
						{
							flSpeed = flOriginalSpeed + NPCGetAnger(npcIndex);
						}
						flTimerCheck = flSpeed / g_SlaughterRunDivisibleTimeConVar.FloatValue;
						flTimes[iBosses] = flTimerCheck;
						iBosses++;
					}
					int iArrayLength = iBosses;
					if (iArrayLength > 0)
					{
						for (int i2 = 0; i2 < iArrayLength; i2++)
						{
							flAverageTime += flTimes[i2];
						}
						flAverageTime = flAverageTime / iArrayLength;
						flAverageTime += (float(iBosses) / 2.0);
						for (int i3 = 0; i3 < iArrayLength; i3++)
						{
							flAverageTime += (flTimes[i3] / GetRandomFloat(12.0, 22.0));
						}
						switch (g_DifficultyConVar.IntValue)
						{
							case Difficulty_Normal: flAverageTime += 1.0;
							case Difficulty_Hard: flAverageTime += 2.0;
							case Difficulty_Insane: flAverageTime += 3.0;
							case Difficulty_Nightmare: flAverageTime += 4.0;
							case Difficulty_Apollyon: flAverageTime += 5.0;
						}
						PrintToChatAll("Time before bosses spawn: %f seconds", flAverageTime);
						CreateTimer(flAverageTime, Timer_SlaughterRunSpawnBosses, _, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
			
			g_PageFoundLastTime = GetGameTime();
		}
		
		SF2MapEntity_OnPageCountChanged(g_PageCount, iOldPageCount);
		
		// Notify logic entities.
		char sTargetName[64];
		char sFindTargetName[64];
		FormatEx(sFindTargetName, sizeof(sFindTargetName), "sf2_onpagecount_%d", g_PageCount);
		
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "logic_relay")) != -1)
		{
			GetEntPropString(ent, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
			if (sTargetName[0] != '\0' && strcmp(sTargetName, sFindTargetName, false) == 0)
			{
				AcceptEntityInput(ent, "Trigger");
				break;
			}
		}
		
		int iClients[MAXPLAYERS + 1] = { -1, ... };
		int iClientsNum = 0;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i)) continue;
			if (!g_PlayerEliminated[i] || IsClientInGhostMode(i))
			{
				if (g_PageCount)
				{
					iClients[iClientsNum] = i;
					iClientsNum++;
				}
			}
		}
		
		if (g_PageCount > 0 && g_bRoundHasEscapeObjective && g_PageCount == g_PageMax)
		{
			// Escape initialized!
			SetRoundState(SF2RoundState_Escape);
			
			if (iClientsNum)
			{
				int iGameTextEscape = -1;
				SF2GameTextEntity gameText = SF2GameTextEntity(-1);
				
				if (g_GamerulesEntity.IsValid() && (gameText = g_GamerulesEntity.EscapeTextEntity).IsValid())
				{
					char sMessage[512];
					gameText.GetEscapeMessage(sMessage, sizeof(sMessage));
					if (gameText.ValidateMessageString(sMessage, sizeof(sMessage)))
					{
						ShowHudTextUsingTextEntity(iClients, iClientsNum, gameText.index, g_HudSync, sMessage);
					}
				}
				else if (IsValidEntity((iGameTextEscape = GetTextEntity("sf2_escape_message", false))))
				{
					// Custom escape message.
					char sMessage[512];
					GetEntPropString(iGameTextEscape, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameTextEscape, g_HudSync, sMessage);
				}
				else
				{
					// Default escape message.
					for (int i = 0; i < iClientsNum; i++)
					{
						int client = iClients[i];
						ClientShowMainMessage(client, "%d/%d\n%T", g_PageCount, g_PageMax, "SF2 Default Escape Message", i);
					}
				}
			}
			
			if (SF_SpecialRound(SPECIALROUND_LASTRESORT))
			{
				char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
				ArrayList hSelectableBosses = GetSelectableBossProfileList().Clone();
				if (hSelectableBosses.Length > 0)
				{
					hSelectableBosses.GetString(GetRandomInt(0, hSelectableBosses.Length - 1), sBuffer, sizeof(sBuffer));
					AddProfile(sBuffer);
				}
				delete hSelectableBosses;
			}
		}
		else
		{
			if (iClientsNum)
			{
				int iGameTextPage = -1;
				SF2GameTextEntity gameText = SF2GameTextEntity(-1);
				
				if (g_GamerulesEntity.IsValid() && (gameText = g_GamerulesEntity.PageTextEntity).IsValid())
				{
					char sMessage[512];
					gameText.GetPageMessage(sMessage, sizeof(sMessage));
					if (gameText.ValidateMessageString(sMessage, sizeof(sMessage)))
					{
						ShowHudTextUsingTextEntity(iClients, iClientsNum, gameText.index, g_HudSync, sMessage);
					}
				}
				else if (IsValidEntity((iGameTextPage = GetTextEntity("sf2_page_message", false))))
				{
					// Custom page message.
					char sMessage[512];
					GetEntPropString(iGameTextPage, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameTextPage, g_HudSync, sMessage, g_PageCount, g_PageMax);
				}
				else
				{
					// Default page message.
					for (int i = 0; i < iClientsNum; i++)
					{
						int client = iClients[i];
						ClientShowMainMessage(client, "%d/%d", g_PageCount, g_PageMax);
					}
				}
			}
		}
		
		CreateTimer(0.2, Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_SlaughterRunSpawnBosses(Handle timer)
{
	ArrayList hSpawnPoint = new ArrayList();
	float flTeleportPos[3];
	int ent = -1, iSpawnTeam = 0;
	while ((ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1)
	{
		iSpawnTeam = GetEntProp(ent, Prop_Data, "m_iInitialTeamNum");
		if (iSpawnTeam == TFTeam_Red)
		{
			hSpawnPoint.Push(ent);
		}
		
	}
	ent = -1;
	
	for (int iNpc = 0; iNpc <= MAX_BOSSES; iNpc++)
	{
		SF2NPC_BaseNPC Npc = view_as<SF2NPC_BaseNPC>(iNpc);
		if (!Npc.IsValid()) continue;
		Npc.UnSpawn();
		if (hSpawnPoint.Length > 0)ent = hSpawnPoint.Get(GetRandomInt(0, hSpawnPoint.Length - 1));
		if (IsValidEntity(ent))
		{
			GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", flTeleportPos);
			SpawnSlender(Npc, flTeleportPos);
		}
	}
	delete hSpawnPoint;
	
	return Plugin_Stop;
}

bool Player_FindFreePosition2(int client, float position[3], float mins[3], float maxs[3])
{
	int team = GetClientTeam(client);
	int mask = MASK_RED;
	if (team != TFTeam_Red) mask = MASK_BLUE;
	
	// -90 to 90
	float pitchMin = 75.0; // down
	float pitchMax = -89.0; // up
	float pitchInc = 10.0;
	
	float yawMin = -180.0;
	float yawMax = 180.0;
	float yawInc = 10.0;
	
	float radiusMin = 150.0; // 150.0
	float radiusMax = 300.0;
	float radiusInc = 25.0; // 25.0
	
	float ang[3];
	
	for (float p = pitchMin; p >= pitchMax; p -= pitchInc)
	{
		ang[0] = p;
		for (float y = yawMin; y <= yawMax; y += yawInc)
		{
			ang[1] = y;
			for (float r = radiusMin; r <= radiusMax; r += radiusInc)
			{
				float freePosition[3];
				GetPositionForward(position, ang, freePosition, r);
				
				// Perform a line of sight check to avoid spawning players in unreachable map locations.
				// The tank has this weird bug where players can be pushed into map displacements and can sometimes go completely through a wall.
				TR_TraceRayFilter(position, freePosition, mask, RayType_EndPoint, TraceRayDontHitPlayersOrEntity);
				
				if (!TR_DidHit())
				{
					TR_TraceHullFilter(freePosition, freePosition, mins, maxs, mask, TraceFilter_NotTeam, team);
					
					if (!TR_DidHit())
					{
						TeleportEntity(client, freePosition, NULL_VECTOR, NULL_VECTOR);
						return true;
					}
				}
				else
				{
					// We hit a wall, breaking line of sight. Give up on this angle.
					break;
				}
			}
		}
	}
	return false;
}
public bool TraceFilter_NotTeam(int entity, int contentsMask, int team)
{
	if (entity >= 1 && entity <= MaxClients && GetClientTeam(entity) == team)
	{
		return false;
	}
	if (IsValidEdict(entity))
	{
		char sClass[64];
		GetEntityClassname(entity, sClass, sizeof(sClass));
		if (strcmp(sClass, "base_npc") == 0 || strcmp(sClass, "base_boss") == 0) return false;
	}
	return true;
}
int GetTextEntity(const char[] sTargetName, bool bCaseSensitive = true)
{
	// Try to see if we can use a custom message instead of the default.
	char targetName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "game_text")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0] != '\0')
		{
			if (strcmp(targetName, sTargetName, bCaseSensitive) == 0)
			{
				return ent;
			}
		}
	}
	
	return -1;
}

void ShowHudTextUsingTextEntity(const int[] iClients, int iClientsNum, int iGameText, Handle hHudSync, const char[] sMessage, any ...)
{
	if (sMessage[0] == '\0') return;
	if (!IsValidEntity(iGameText)) return;
	
	char sTrueMessage[512];
	VFormat(sTrueMessage, sizeof(sTrueMessage), sMessage, 6);
	
	float flX = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.x");
	float flY = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.y");
	int iEffect = GetEntProp(iGameText, Prop_Data, "m_textParms.effect");
	float flFadeInTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeinTime");
	float flFadeOutTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeoutTime");
	float flHoldTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.holdTime");
	float flFxTime = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fxTime");
	
	int Color1[4] = { 255, 255, 255, 255 };
	int Color2[4] = { 255, 255, 255, 255 };
	
	int iParmsOffset = FindDataMapInfo(iGameText, "m_textParms");
	if (iParmsOffset != -1)
	{
		// hudtextparms_s m_textParms
		
		Color1[0] = GetEntData(iGameText, iParmsOffset + 12, 1);
		Color1[1] = GetEntData(iGameText, iParmsOffset + 13, 1);
		Color1[2] = GetEntData(iGameText, iParmsOffset + 14, 1);
		Color1[3] = GetEntData(iGameText, iParmsOffset + 15, 1);
		
		Color2[0] = GetEntData(iGameText, iParmsOffset + 16, 1);
		Color2[1] = GetEntData(iGameText, iParmsOffset + 17, 1);
		Color2[2] = GetEntData(iGameText, iParmsOffset + 18, 1);
		Color2[3] = GetEntData(iGameText, iParmsOffset + 19, 1);
	}
	
	SetHudTextParamsEx(flX, flY, flHoldTime, Color1, Color2, iEffect, flFxTime, flFadeInTime, flFadeOutTime);
	
	for (int i = 0; i < iClientsNum; i++)
	{
		int client = iClients[i];
		if (!IsValidClient(client) || IsFakeClient(client)) continue;
		
		ShowSyncHudText(client, hHudSync, sTrueMessage);
	}
}

void DistributeQueuePointsToPlayers()
{
	// Give away queue points.
	int iDefaultAmount = 5;
	int iAmount = iDefaultAmount;
	int iAmount2 = iAmount;
	Action iAction = Plugin_Continue;
	
	for (int i = 0; i < SF2_MAX_PLAYER_GROUPS; i++)
	{
		if (!IsPlayerGroupActive(i)) continue;
		
		if (IsPlayerGroupPlaying(i))
		{
			SetPlayerGroupQueuePoints(i, 0);
		}
		else
		{
			iAmount = iDefaultAmount;
			iAmount2 = iAmount;
			iAction = Plugin_Continue;
			
			Call_StartForward(g_OnGroupGiveQueuePointsFwd);
			Call_PushCell(i);
			Call_PushCellRef(iAmount2);
			Call_Finish(iAction);
			
			if (iAction == Plugin_Changed)iAmount = iAmount2;
			
			SetPlayerGroupQueuePoints(i, GetPlayerGroupQueuePoints(i) + iAmount);
			
			for (int client = 1; client <= MaxClients; client++)
			{
				if (!IsValidClient(client)) continue;
				if (ClientGetPlayerGroup(client) == i)
				{
					CPrintToChat(client, "%T", "SF2 Give Group Queue Points", client, iAmount);
				}
			}
		}
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (g_AdminNoPoints[i]) continue;
		if (g_bPlayerPlaying[i])
		{
			ClientSetQueuePoints(i, 0);
		}
		else
		{
			if (!IsClientParticipating(i))
			{
				CPrintToChat(i, "%T", "SF2 No Queue Points To Spectator", i);
			}
			else
			{
				iAmount = iDefaultAmount;
				iAmount2 = iAmount;
				iAction = Plugin_Continue;
				
				Call_StartForward(g_OnClientGiveQueuePointsFwd);
				Call_PushCell(i);
				Call_PushCellRef(iAmount2);
				Call_Finish(iAction);
				
				if (iAction == Plugin_Changed)iAmount = iAmount2;
				
				ClientSetQueuePoints(i, g_iPlayerQueuePoints[i] + iAmount);
				CPrintToChat(i, "%T", "SF2 Give Queue Points", i, iAmount);
			}
		}
	}
}

/**
 *	Sets the player to the correct team if needed. Returns true if a change was necessary, false if no change occurred.
 */
bool HandlePlayerTeam(int client, bool bRespawn=true)
{
	if (!IsClientInGame(client) || !IsClientParticipating(client)) return false;
	
	if (!g_PlayerEliminated[client])
	{
		if (GetClientTeam(client) != TFTeam_Red)
		{
			if (bRespawn)
			{
				TF2_RemoveCondition(client,TFCond_HalloweenKart);
				TF2_RemoveCondition(client,TFCond_HalloweenKartDash);
				TF2_RemoveCondition(client,TFCond_HalloweenKartNoTurn);
				TF2_RemoveCondition(client,TFCond_HalloweenKartCage);
				TF2_RemoveCondition(client, TFCond_SpawnOutline);
				ChangeClientTeamNoSuicide(client, TFTeam_Red);
			}
			else
				ChangeClientTeam(client, TFTeam_Red);
				
			return true;
		}
	}
	else
	{
		if (GetClientTeam(client) != TFTeam_Blue)
		{
			if (bRespawn)
			{
				TF2_RemoveCondition(client,TFCond_HalloweenKart);
				TF2_RemoveCondition(client,TFCond_HalloweenKartDash);
				TF2_RemoveCondition(client,TFCond_HalloweenKartNoTurn);
				TF2_RemoveCondition(client,TFCond_HalloweenKartCage);
				TF2_RemoveCondition(client, TFCond_SpawnOutline);
				ChangeClientTeamNoSuicide(client, TFTeam_Blue);
			}
			else
				ChangeClientTeam(client, TFTeam_Blue);
				
			return true;
		}
	}
	
	return false;
}

void HandlePlayerIntroState(int client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || !IsClientParticipating(client)) return;
	
	if (!IsRoundInIntro()) return;
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 2) DebugMessage("START HandlePlayerIntroState(%d)", client);
	#endif
	
	// Disable movement on player.
	SetEntityFlags(client, GetEntityFlags(client) | FL_FROZEN);
	
	float flDelay = 0.0;
	if (!IsFakeClient(client))
	{
		flDelay = GetClientLatency(client, NetFlow_Outgoing);
	}
	
	CreateTimer(flDelay * 4.0, Timer_IntroBlackOut, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 2) DebugMessage("END HandlePlayerIntroState(%d)", client);
	#endif
}

void HandlePlayerHUD(int client)
{
	if (SF_IsRaidMap() || SF_IsBoxingMap())
		return;
	if (IsRoundInWarmup() || IsClientInGhostMode(client))
	{
		SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
	}
	else
	{
		if (!g_PlayerEliminated[client])
		{
			if (!DidClientEscape(client))
			{
				// Player is in the game; disable normal HUD.
				SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_CROSSHAIR | HIDEHUD_HEALTH);
			}
			else
			{
				// Player isn't in the game; enable normal HUD behavior.
				SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
			}
		}
		else
		{
			if (g_PlayerProxy[client])
			{
				// Player is in the game; disable normal HUD.
				SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_CROSSHAIR | HIDEHUD_HEALTH);
			}
			else
			{
				// Player isn't in the game; enable normal HUD behavior.
				SetEntProp(client, Prop_Send, "m_iHideHUD", 0);
			}
		}
	}
}

public Action Timer_SwitchBot(Handle timer, any userid)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (GetClientTeam(client) != TFTeam_Red || DidClientEscape(client)) return Plugin_Stop;
	
	if (!IsPlayerAlive(client)) return Plugin_Stop;
	
	int iRandom = GetRandomInt(1, 9);
	TFClassType tfNewClass;
	switch (iRandom)
	{
		case 1:tfNewClass = TFClass_Scout;
		case 2:tfNewClass = TFClass_Soldier;
		case 3:tfNewClass = TFClass_Pyro;
		case 4:tfNewClass = TFClass_DemoMan;
		case 5:tfNewClass = TFClass_Heavy;
		case 6:tfNewClass = TFClass_Engineer;
		case 7:tfNewClass = TFClass_Medic;
		case 8:tfNewClass = TFClass_Sniper;
		case 9:tfNewClass = TFClass_Spy;
	}
	TF2_SetPlayerClass(client, tfNewClass);
	TF2_RegeneratePlayer(client);
	
	return Plugin_Stop;
}

public Action Timer_IntroBlackOut(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (!IsRoundInIntro()) return Plugin_Stop;
	
	if (!IsPlayerAlive(client) || g_PlayerEliminated[client]) return Plugin_Stop;
	
	// Black out the player's screen.
	int iFadeFlags = FFADE_OUT | FFADE_STAYOUT | FFADE_PURGE;
	UTIL_ScreenFade(client, 0, FixedUnsigned16(90.0, 1 << 12), iFadeFlags, g_iRoundIntroFadeColor[0], g_iRoundIntroFadeColor[1], g_iRoundIntroFadeColor[2], g_iRoundIntroFadeColor[3]);
	
	return Plugin_Stop;
}

int GetClientForDeath(int exclude1, int exclude2 = 0)
{
	if (g_UsePlayersForKillFeedConVar.BoolValue)
	{
		// Use AFKs first
		for (int i = 1; i <= MaxClients; i++)
		{
			if (i != exclude1 && i != exclude2 && IsClientInGame(i) && GetClientTeam(i) > TFTeam_Spectator && g_PlayerNoPoints[i])
				return i;
		}

		// Use BLU second
		for (int i = 1; i <= MaxClients; i++)
		{
			if (i != exclude1 && i != exclude2 && IsClientInGame(i) && GetClientTeam(i) == TFTeam_Blue)
				return i;
		}

		// Anyone else last
		for (int i = 1; i <= MaxClients; i++)
		{
			if (i != exclude1 && i != exclude2 && IsClientInGame(i))
				return i;
		}
	}
	return -1;
}

public Action Hook_TriggerNPCTouch(int iTrigger, int iOther)
{
	int flags = GetEntProp(iTrigger, Prop_Data, "m_spawnflags");
	if ((flags & TRIGGER_CLIENTS) && MaxClients >= iOther > 0) return Plugin_Continue;
	if (MAX_BOSSES >= NPCGetFromEntIndex(iOther) > -1) return Plugin_Continue;
	
	return Plugin_Handled;
}

public Action Timer_ToggleGhostModeCommand(Handle timer, any userid)
{
	if (!g_Enabled) return Plugin_Stop;
	
	int client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (IsRoundEnding() || IsRoundInWarmup() || !g_PlayerEliminated[client] || !IsClientParticipating(client) || g_PlayerProxy[client] || IsClientInPvP(client) || IsClientInKart(client) || TF2_IsPlayerInCondition(client, TFCond_Taunting) || TF2_IsPlayerInCondition(client, TFCond_Charging))
	{
		CPrintToChat(client, "{red}%T", "SF2 Ghost Mode Not Allowed", client);
		return Plugin_Stop;
	}
	if (!IsClientInGhostMode(client))
	{
		TF2_RespawnPlayer(client);
		ClientSetGhostModeState(client, true);
		HandlePlayerHUD(client);
		TF2_AddCondition(client, TFCond_StealthedUserBuffFade, -1.0);
		
		CPrintToChat(client, "{dodgerblue}%T", "SF2 Ghost Mode Enabled", client);
	}
	
	return Plugin_Stop;
}

public Action Timer_SendDeath(Handle timer, Event event)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client > 0)
	{
		int iIgnore = event.GetInt("ignore");
		if (!iIgnore)
		{
			//Delay event until their name is correct
			int iAttacker = GetClientOfUserId(event.GetInt("attacker"));
			if (iAttacker > 0 && iAttacker <= MaxClients && g_TimerChangeClientName[iAttacker])
				return Plugin_Continue;
		}

		//Send it to the clients
		for (int i = 1; i<=MaxClients; i++)
		{
			if (i != iIgnore && IsValidClient(i))
			{
				if (!g_PlayerEliminated[client] || g_PlayerEliminated[i] || GetClientTeam(client) == GetClientTeam(i)) event.FireToClient(i);
			}
		}
	}
	event.Cancel();
	return Plugin_Stop;
}

public Action Timer_SendDeathToSpecific(Handle timer, Event event)
{
	int client = GetClientOfUserId(event.GetInt("send"));
	if (client > 0)
		event.FireToClient(client);

	event.Cancel();
	return Plugin_Stop;
}

public Action Timer_RevertClientName(Handle timer, int index)
{
	g_TimerChangeClientName[index] = null;
	if (IsClientInGame(index))
	{
		//TF2_ChangePlayerName(iSourceTV, g_sOldClientName[index], true);
		SetClientName(index, g_sOldClientName[index]);
		SetEntPropString(index, Prop_Data, "m_szNetname", g_sOldClientName[index]);
	}
	return Plugin_Continue;
}

public Action Timer_CheckAlivePlayers(Handle timer)
{
	if (!g_Enabled || !SF_IsBoxingMap()) return Plugin_Stop;
	
	int iClients[MAXPLAYERS + 1];
	int iClientsNum;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !IsClientInGame(i) || g_PlayerEliminated[i]) continue;
		
		iClients[iClientsNum] = i;
		iClientsNum++;
	}
	
	switch (iClientsNum)
	{
		case 1:
		{
			for (int i = 0; i < iClientsNum; i++)
			{
				int client = iClients[i];
				TF2_AddCondition(client, TFCond_HalloweenCritCandy, -1.0);
			}
			if (!g_PlayersAreCritted)
			{
				if (g_RoundTime > 120)
				{
					SetRoundTime(120);
					CPrintToChatAll("Only 1 {red}RED{default} player is alive, 2 minutes left on the timer...");
					for (int npcIndex = 0; npcIndex < MAX_BOSSES; npcIndex++)
					{
						if (NPCGetUniqueID(npcIndex) == -1) continue;
						NPCSetAddSpeed(npcIndex, 50.0);
						NPCSetAddMaxSpeed(npcIndex, 75.0);
						NPCSetAddAcceleration(npcIndex, 250.0);
					}
					g_PlayersAreCritted = true;
				}
				else
				{
					CPrintToChatAll("Only 1 {red}RED{default} player is alive...");
					for (int npcIndex = 0; npcIndex < MAX_BOSSES; npcIndex++)
					{
						if (NPCGetUniqueID(npcIndex) == -1) continue;
						NPCSetAddSpeed(npcIndex, 50.0);
						NPCSetAddMaxSpeed(npcIndex, 75.0);
						NPCSetAddAcceleration(npcIndex, 250.0);
					}
					g_PlayersAreCritted = true;
				}
			}
		}
		case 2, 3:
		{
			if (!g_PlayersAreMiniCritted)
			{
				if (g_RoundTime > 200)
				{
					SetRoundTime(200);
					CPrintToChatAll("3 {red}RED{default} players are alive, 3 minutes and 20 seconds left on the timer...");
					for (int i = 0; i < iClientsNum; i++)
					{
						int client = iClients[i];
						TF2_AddCondition(client, TFCond_Buffed, -1.0);
					}
					g_PlayersAreMiniCritted = true;
				}
				else
				{
					CPrintToChatAll("3 {red}RED{default} players are alive...");
					for (int i = 0; i < iClientsNum; i++)
					{
						int client = iClients[i];
						TF2_AddCondition(client, TFCond_Buffed, -1.0);
					}
					g_PlayersAreMiniCritted = true;
				}
			}
		}
		default:
		{
			for (int i = 0; i < iClientsNum; i++)
			{
				int client = iClients[i];
				TF2_RemoveCondition(client, TFCond_Buffed);
				TF2_RemoveCondition(client, TFCond_HalloweenCritCandy);
			}
			g_PlayersAreCritted = false;
			g_PlayersAreMiniCritted = false;
		}
	}
	return Plugin_Stop;
}

public Action Timer_ReplacePlayerRagdoll(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Stop;
	}
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Stop;
	}
	int ent = CreateEntityByName("tf_ragdoll", -1);
	if (ent != -1)
	{
		float pos[3], ang[3], velocity[3], force[3];
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
		GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
		SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
		SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
		SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
		SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
		SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
		SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
		SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
		SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
		SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
		SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
		SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
		SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));
		SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
		SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
		SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
		int iDeathType = GetRandomInt(1, 8);
		switch (iDeathType)
		{
			case 1:
			{
				velocity[0] = 40.0;
				velocity[1] = 40.0;
				velocity[2] = 40.0;
				force[0] = 40.0;
				force[1] = 40.0;
				force[2] = 40.0;
				ScaleVector(velocity, 10000.0);
				ScaleVector(force, 10000.0);
				velocity[0] = 0.0;
				velocity[1] = 0.0;
				force[0] = 0.0;
				force[1] = 0.0;
				SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
				SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
			}
			case 2:
			{
				SetEntProp(ent, Prop_Send, "m_bGib", true);
			}
			case 3:
			{
				SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", true);
			}
			case 4:
			{
				SetEntProp(ent, Prop_Send, "m_bIceRagdoll", true);
			}
			case 5:
			{
				SetEntProp(ent, Prop_Send, "m_bBecomeAsh", true);
			}
			case 6:
			{
				SetEntProp(ent, Prop_Send, "m_bBurning", true);
			}
			case 7:
			{
				SetEntProp(ent, Prop_Send, "m_bElectrocuted", true);
			}
			case 8:
			{
				velocity[0] = 40.0;
				velocity[1] = 40.0;
				velocity[2] = 40.0;
				force[0] = 40.0;
				force[1] = 40.0;
				force[2] = 40.0;
				MakeVectorFromPoints(pos, view_as<float>( { 0.0, 0.0, 0.0 } ), velocity);
				ScaleVector(velocity, 20000.0);
				ScaleVector(force, 20000.0);
				SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
				SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
			}
		}
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
	}
	RemoveEntity(ragdoll);
	return Plugin_Stop;
}

public Action Timer_IceRagdoll(Handle timer, any userid)
{
	
	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Stop;
	}
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Stop;
	}
	int ent = CreateEntityByName("tf_ragdoll", -1);
	if (ent != -1)
	{
		float pos[3], ang[3], velocity[3], force[3];
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
		GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
		SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
		SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
		SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
		SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
		SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
		SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
		SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
		SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
		SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
		SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
		SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
		SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));
		SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
		SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
		SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
		int iIce = GetRandomInt(1, 2);
		switch (iIce)
		{
			case 1:
			{
				SetEntProp(ent, Prop_Send, "m_bIceRagdoll", true);
			}
			case 2:
			{
				SetEntProp(ent, Prop_Send, "m_bIceRagdoll", true);
			}
		}
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
	}
	AcceptEntityInput(ragdoll, "Kill", -1, -1, 0);
	return Plugin_Stop;
}

public Action Timer_ManglerRagdoll(Handle timer, any userid)
{
	
	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Stop;
	}
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Stop;
	}
	int ent = CreateEntityByName("tf_ragdoll", -1);
	if (ent != -1)
	{
		float pos[3], ang[3], velocity[3], force[3];
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
		GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
		SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
		SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
		SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
		SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
		SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
		SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
		SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
		SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
		SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
		SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
		SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
		SetEntProp(ent, Prop_Send, "m_iDamageCustom", TF_CUSTOM_PLASMA);
		SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
		SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
		SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
	}
	AcceptEntityInput(ragdoll, "Kill", -1, -1, 0);
	return Plugin_Stop;
}

public Action Timer_AshRagdoll(Handle timer, any userid)
{
	
	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Stop;
	}
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Stop;
	}
	int ent = CreateEntityByName("tf_ragdoll", -1);
	if (ent != -1)
	{
		float pos[3], ang[3], velocity[3], force[3];
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
		GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
		SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
		SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
		SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
		SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
		SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
		SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
		SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
		SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
		SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
		SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
		SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
		SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));
		SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
		SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
		SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
		int iAsh = GetRandomInt(1, 2);
		switch (iAsh)
		{
			case 1:
			{
				SetEntProp(ent, Prop_Send, "m_bBecomeAsh", true);
			}
			case 2:
			{
				SetEntProp(ent, Prop_Send, "m_bBecomeAsh", true);
			}
		}
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
	}
	AcceptEntityInput(ragdoll, "Kill", -1, -1, 0);
	return Plugin_Stop;
}

public Action Timer_DeGibRagdoll(Handle timer, any userid)
{

	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Continue;
	}
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Continue;
	}
	int ent = CreateEntityByName("tf_ragdoll", -1);
	if (ent != -1)
	{
		float pos[3], ang[3], velocity[3], force[3];
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
		GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
		SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
		SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
		SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
		SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
		SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
		SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
		SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
		SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
		SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
		SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
		SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
		SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));
		SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
		SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
		SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
		int iDeGib = GetRandomInt(1, 2);
		switch (iDeGib)
		{
			case 1:
			{
				SetEntProp(ent, Prop_Send, "m_iDamageCustom", TF_CUSTOM_DECAPITATION);
			}
			case 2:
			{
				SetEntProp(ent, Prop_Send, "m_bGib", true);
			}
		}
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
	}
	AcceptEntityInput(ragdoll, "Kill", -1, -1, 0);
	return Plugin_Continue;
}

public Action Timer_MultiRagdoll(Handle timer, any userid)
{

	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Continue;
	}
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Continue;
	}
	int ent = CreateEntityByName("tf_ragdoll", -1);
	if (ent != -1)
	{
		float pos[3], ang[3], velocity[3], force[3];
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
		GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
		GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
		TeleportEntity(ent, pos, ang, NULL_VECTOR);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
		SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
		SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
		SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
		SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
		SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
		SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
		SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
		SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
		SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
		SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
		SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
		SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
		SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
		SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));
		SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
		SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
		SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
		SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
		int iMulti = GetRandomInt(1, 9);
		switch (iMulti)
		{
			case 1:
			{
				SetEntProp(ent, Prop_Send, "m_bGib", true);
			}
			case 2:
			{
				SetEntProp(ent, Prop_Send, "m_bBurning", true);
			}
			case 3:
			{
				SetEntProp(ent, Prop_Send, "m_bBecomeAsh", true);
			}
			case 4:
			{
				SetEntProp(ent, Prop_Send, "m_iDamageCustom", TF_CUSTOM_DECAPITATION);
			}
			case 5:
			{
				SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", true);
			}			
			case 6:
			{
				SetEntProp(ent, Prop_Send, "m_bIceRagdoll", true);
			}
			case 7:
			{
				SetEntProp(ent, Prop_Send, "m_bElectrocuted", true);
			}
			case 8:
			{
				SetEntProp(ent, Prop_Send, "m_bCloaked", true);
			}
			case 9:
			{
				SetEntProp(ent, Prop_Send, "m_iDamageCustom", TF_CUSTOM_PLASMA);
			}
		}
		DispatchSpawn(ent);
		ActivateEntity(ent);
		SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
	}
	AcceptEntityInput(ragdoll, "Kill", -1, -1, 0);
	return Plugin_Continue;
}

public Action Timer_ModifyRagdoll(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (0 >= client)
	{
		return Plugin_Stop;
	}
	int iSlender = EntRefToEntIndex(g_iPlayerBossKillSubject[client]);
	if (!iSlender || iSlender == INVALID_ENT_REFERENCE) return Plugin_Stop;
	int bossIndex = NPCGetFromEntIndex(iSlender);
	if (bossIndex == -1) return Plugin_Stop;
	char profile[SF2_MAX_PROFILE_NAME_LENGTH];
	NPCGetProfile(bossIndex, profile, sizeof(profile));
	int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	if (!IsValidEntity(ragdoll))
	{
		return Plugin_Stop;
	}
	if (!g_bSlenderHasDeleteKillEffect[bossIndex])
	{
		int ent = CreateEntityByName("tf_ragdoll", -1);
		if (ent != -1)
		{
			float pos[3], ang[3], velocity[3], force[3];
			GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", pos);
			GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", velocity);
			GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", force);
			GetEntPropVector(ragdoll, Prop_Data, "m_angAbsRotation", ang);
			TeleportEntity(ent, pos, ang, NULL_VECTOR);
			SetEntPropVector(ent, Prop_Send, "m_vecRagdollOrigin", pos);
			if (g_bSlenderHasPushRagdollOnKill[bossIndex])
			{
				float flForce[3];
				GetProfileVector(profile, "push_ragdoll_force", flForce);
				SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", flForce);
				SetEntPropVector(ent, Prop_Send, "m_vecForce", flForce);
			}
			else
			{
				SetEntPropVector(ent, Prop_Send, "m_vecRagdollVelocity", velocity);
				SetEntPropVector(ent, Prop_Send, "m_vecForce", force);
			}
			if (g_bSlenderHasResizeRagdollOnKill[bossIndex])
			{
				SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", g_SlenderResizeRagdollHead[bossIndex]);
				SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", g_SlenderResizeRagdollTorso[bossIndex]);
				SetEntPropFloat(ent, Prop_Send, "m_flHandScale", g_SlenderResizeRagdollHands[bossIndex]);
			}
			else
			{
				SetEntPropFloat(ent, Prop_Send, "m_flHeadScale", 1.0);
				SetEntPropFloat(ent, Prop_Send, "m_flTorsoScale", 1.0);
				SetEntPropFloat(ent, Prop_Send, "m_flHandScale", 1.0);
			}
			SetEntProp(ent, Prop_Send, "m_nForceBone", GetEntProp(ragdoll, Prop_Send, "m_nForceBone"));
			SetEntProp(ent, Prop_Send, "m_bOnGround", GetEntProp(ragdoll, Prop_Send, "m_bOnGround"));
			
			if (g_bSlenderHasCloakKillEffect[bossIndex])SetEntProp(ent, Prop_Send, "m_bCloaked", true);
			else SetEntProp(ent, Prop_Send, "m_bCloaked", GetEntProp(ragdoll, Prop_Send, "m_bCloaked"));
			
			SetEntProp(ent, Prop_Send, "m_iPlayerIndex", GetEntProp(ragdoll, Prop_Send, "m_iPlayerIndex"));
			SetEntProp(ent, Prop_Send, "m_iTeam", GetEntProp(ragdoll, Prop_Send, "m_iTeam"));
			SetEntProp(ent, Prop_Send, "m_iClass", GetEntProp(ragdoll, Prop_Send, "m_iClass"));
			SetEntProp(ent, Prop_Send, "m_bWasDisguised", GetEntProp(ragdoll, Prop_Send, "m_bWasDisguised"));
			SetEntProp(ent, Prop_Send, "m_bFeignDeath", GetEntProp(ragdoll, Prop_Send, "m_bFeignDeath"));
			
			if (g_bSlenderHasGibKillEffect[bossIndex])SetEntProp(ent, Prop_Send, "m_bGib", true);
			else SetEntProp(ent, Prop_Send, "m_bGib", GetEntProp(ragdoll, Prop_Send, "m_bGib"));
			
			if (g_bSlenderHasDecapKillEffect[bossIndex])SetEntProp(ent, Prop_Send, "m_iDamageCustom", TF_CUSTOM_DECAPITATION);
			else if (g_bSlenderHasPlasmaRagdollOnKill[bossIndex])SetEntProp(ent, Prop_Send, "m_iDamageCustom", TF_CUSTOM_PLASMA);
			else SetEntProp(ent, Prop_Send, "m_iDamageCustom", GetEntProp(ragdoll, Prop_Send, "m_iDamageCustom"));
			
			if (g_bSlenderHasBurnKillEffect[bossIndex])SetEntProp(ent, Prop_Send, "m_bBurning", true);
			else SetEntProp(ent, Prop_Send, "m_bBurning", GetEntProp(ragdoll, Prop_Send, "m_bBurning"));
			
			if (g_bSlenderHasAshKillEffect[bossIndex])
				SetEntProp(ent, Prop_Send, "m_bBecomeAsh", true);
			else SetEntProp(ent, Prop_Send, "m_bBecomeAsh", GetEntProp(ragdoll, Prop_Send, "m_bBecomeAsh"));
			
			if (g_bSlenderHasGoldKillEffect[bossIndex])SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", true);
			else SetEntProp(ent, Prop_Send, "m_bGoldRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bGoldRagdoll"));
			
			if (g_bSlenderHasIceKillEffect[bossIndex])SetEntProp(ent, Prop_Send, "m_bIceRagdoll", true);
			else SetEntProp(ent, Prop_Send, "m_bIceRagdoll", GetEntProp(ragdoll, Prop_Send, "m_bIceRagdoll"));
			
			if (g_bSlenderHasElectrocuteKillEffect[bossIndex])SetEntProp(ent, Prop_Send, "m_bElectrocuted", true);
			else SetEntProp(ent, Prop_Send, "m_bElectrocuted", GetEntProp(ragdoll, Prop_Send, "m_bElectrocuted"));
			
			DispatchSpawn(ent);
			ActivateEntity(ent);
			SetEntPropEnt(client, Prop_Send, "m_hRagdoll", ent, 0);
		}
		if (g_bSlenderHasDissolveRagdollOnKill[bossIndex])
		{
			int dissolver = CreateEntityByName("env_entity_dissolver");
			if (!IsValidEntity(dissolver))
			{
				return Plugin_Stop;
			}
			char sType[2];
			int iType = g_iSlenderDissolveRagdollType[bossIndex];
			FormatEx(sType, sizeof(sType), "%d", iType);
			DispatchKeyValue(dissolver, "dissolvetype", sType);
			DispatchKeyValue(dissolver, "magnitude", "1");
			DispatchKeyValue(dissolver, "target", "!activator");
			
			AcceptEntityInput(dissolver, "Dissolve", ent);
			RemoveEntity(dissolver);
		}
	}
	RemoveEntity(ragdoll);
	return Plugin_Stop;
}

public Action Timer_SetPlayerHealth(Handle timer, any data)
{
	Handle hPack = view_as<Handle>(data);
	ResetPack(hPack);
	int iAttacker = GetClientOfUserId(ReadPackCell(hPack));
	int iHealth = ReadPackCell(hPack);
	delete hPack;
	
	if (iAttacker <= 0) return Plugin_Stop;
	
	SetEntProp(iAttacker, Prop_Data, "m_iHealth", iHealth);
	SetEntProp(iAttacker, Prop_Send, "m_iHealth", iHealth);
	
	return Plugin_Stop;
}

public Action Timer_PlayerSwitchToBlue(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	
	if (timer != g_hPlayerSwitchBlueTimer[client]) return Plugin_Stop;
	if (g_IgnoreRedPlayerDeathSwapConVar.BoolValue) return Plugin_Stop;

	ChangeClientTeam(client, TFTeam_Blue);
	
	if (TF2_GetPlayerClass(client) == view_as<TFClassType>(0))
	{
		// Player hasn't chosen a class for some reason. Choose one for him.
		TF2_SetPlayerClass(client, view_as<TFClassType>(GetRandomInt(1, 9)), true, true);
	}
	
	return Plugin_Stop;
}

stock int ProjectileGetFlags(int projectile)
{
	return g_ProjectileFlags[projectile];
}

stock void ProjectileSetFlags(int projectile, int iFlags)
{
	g_ProjectileFlags[projectile] = iFlags;
}

stock int AttachParticle(int entity, char[] particleType, float posOffset[3] = { 0.0, 0.0, 0.0 } )
{
	int particle = CreateEntityByName("info_particle_system");
	
	if (IsValidEntity(particle))
	{
		SetEntPropEnt(particle, Prop_Data, "m_hOwnerEntity", entity);
		DispatchKeyValue(particle, "effect_name", particleType);
		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", entity, particle, 0);
		float vec_start[3];
		TeleportEntity(particle, vec_start, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(particle);
		
		AcceptEntityInput(particle, "start");
		ActivateEntity(particle);
		
		return EntIndexToEntRef(particle);
	}
	return -1;
}

void CreateGeneralParticle(int entity, const char[] sSectionName, float flParticleZPos = 0.0)
{
	if (entity == -1) return;
	
	float flSlenderPosition[3], flSlenderAngles[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flSlenderPosition);
	GetEntPropVector(entity, Prop_Data, "m_angAbsRotation", flSlenderAngles);
	flSlenderPosition[2] += flParticleZPos;

	DispatchParticleEffect(entity, sSectionName, flSlenderPosition, flSlenderAngles, flSlenderPosition);
}

public Action Timer_RoundStart(Handle timer)
{
	if (g_PageMax > 0)
	{
		ArrayList hArrayClients = new ArrayList();
		#if defined DEBUG
		SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been created for hArrayClients in Timer_RoundStart.", hArrayClients);
		#endif
		int iClients[MAXPLAYERS + 1];
		int iClientsNum = 0;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i) || g_PlayerEliminated[i]) continue;
			
			hArrayClients.Push(GetClientUserId(i));
			iClients[iClientsNum] = i;
			iClientsNum++;
		}
		
		// Show difficulty menu.
		if (!SF_IsBoxingMap() && !SF_IsRenevantMap() && !SF_SpecialRound(SPECIALROUND_MODBOSSES))
		{
			if (iClientsNum)
			{
				// Automatically set it to Normal.
				g_DifficultyConVar.SetInt(Difficulty_Normal);
				
				g_hVoteTimer = CreateTimer(1.0, Timer_VoteDifficulty, hArrayClients, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
				TriggerTimer(g_hVoteTimer, true);
				
				int iGameText = -1;
				char sMessage[512];
				
				if (g_GamerulesEntity.IsValid() && g_GamerulesEntity.IntroTextEntity.IsValid())
				{
					// Do nothing; already being handled.
				}
				else if ((iGameText = GetTextEntity("sf2_intro_message", false)) != -1)
				{
					GetEntPropString(iGameText, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
					ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameText, g_HudSync, sMessage);
				}
				else
				{
					for (int i = 0; i < iClientsNum; i++)
					{
						int client = iClients[i];
						FormatEx(sMessage, sizeof(sMessage), "%T", g_PageMax > 1 ? "SF2 Default Intro Message Plural" : "SF2 Default Intro Message Singular", client, g_PageMax);
						ClientShowMainMessage(client, sMessage);
					}
				}
			}
			else
			{
				delete hArrayClients;
				#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been deleted for hArrayClients in Timer_RoundStart due to 0 clients.", hArrayClients);
				#endif
			}
		}
		else
		{
			delete hArrayClients;
			#if defined DEBUG
			SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been deleted for hArrayClients in Timer_RoundStart.", hArrayClients);
			#endif
		}
	}
	
	return Plugin_Stop;
}

public Action Timer_CheckRoundWinConditions(Handle timer)
{
	CheckRoundWinConditions();
	return Plugin_Stop;
}

public Action Timer_RoundGrace(Handle timer)
{
	if (timer != g_hRoundGraceTimer) return Plugin_Stop;
	
	SetRoundState(SF2RoundState_Active);
	return Plugin_Stop;
}

public Action Timer_RoundTime(Handle timer)
{
	if (timer != g_hRoundTimer) return Plugin_Stop;
	
	if (g_RoundTime <= 0)
	{
		//The round ended trigger a security timer.
		SF_FailEnd();
		SF_FailRoundEnd(2.0);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || g_PlayerEliminated[i] || IsClientInGhostMode(i)) continue;
			
			float flBuffer[3];
			GetClientAbsOrigin(i, flBuffer);
			ClientStartDeathCam(i, 0, flBuffer, true);
			if (SF_SpecialRound(SPECIALROUND_1UP))
			{
				g_PlayerDied1Up[i] = false;
				g_PlayerIn1UpCondition[i] = false;
				g_bPlayerFullyDied1Up[i] = true;
			}
			KillClient(i);
		}
		
		return Plugin_Stop;
	}
	if (SF_SpecialRound(SPECIALROUND_REVOLUTION))
	{
		if (g_iSpecialRoundTime % 60 == 0)
		{
			SpecialRoundCycleStart();
		}
	}
	
	if (g_IsSpecialRound)
		g_iSpecialRoundTime++;
	
	if (!g_bRoundTimerPaused)
	{
		SetRoundTime(g_RoundTime - 1);
	}
	
	int hours, minutes, seconds;
	FloatToTimeHMS(float(g_RoundTime), hours, minutes, seconds);
	
	SetHudTextParams(-1.0, 0.1, 
		1.0, 
		SF2_HUD_TEXT_COLOR_R, SF2_HUD_TEXT_COLOR_G, SF2_HUD_TEXT_COLOR_B, SF2_HUD_TEXT_COLOR_A, 
		_, 
		_, 
		1.5, 1.5);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || (g_PlayerEliminated[i] && !IsClientInGhostMode(i))) continue;
		if (SF_SpecialRound(SPECIALROUND_EYESONTHECLOACK))
			ShowSyncHudText(i, g_RoundTimerSync, "%d/%d\n??:??", g_PageCount, g_PageMax);
		else
			ShowSyncHudText(i, g_RoundTimerSync, "%d/%d\n%d:%02d", g_PageCount, g_PageMax, minutes, seconds);
	}
	
	return Plugin_Continue;
}

public Action Timer_RoundTimeEscape(Handle timer)
{
	if (timer != g_hRoundTimer) return Plugin_Stop;
	
	if (g_RoundTime <= 0)
	{
		//The round ended trigger a security timer.
		SF_FailEnd();
		SF_FailRoundEnd(2.0);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || !IsPlayerAlive(i) || g_PlayerEliminated[i] || IsClientInGhostMode(i) || DidClientEscape(i)) continue;
			
			float flBuffer[3];
			GetClientAbsOrigin(i, flBuffer);
			ClientStartDeathCam(i, 0, flBuffer, true);
			if (SF_SpecialRound(SPECIALROUND_1UP))
			{
				g_PlayerDied1Up[i] = false;
				g_PlayerIn1UpCondition[i] = false;
				g_bPlayerFullyDied1Up[i] = true;
			}
			KillClient(i);
		}
		return Plugin_Stop;
	}
	
	if (SF_SpecialRound(SPECIALROUND_REVOLUTION))
	{
		if (g_iSpecialRoundTime % 60 == 0)
		{
			SpecialRoundCycleStart();
		}
	}
	
	if ((1.0 - ((float(g_RoundTime)) / (float(g_RoundEscapeTimeLimit + g_iTimeEscape)))) >= 0.65)
	{
		if (!g_InProxySurvivalRageMode && !SF_IsRenevantMap())
		{
			bool bProxyBoss = false;
			for (int bossIndex = 0; bossIndex < MAX_BOSSES; bossIndex++)
			{
				if (NPCGetUniqueID(bossIndex) == -1) continue;
				
				if (!(NPCGetFlags(bossIndex) & SFF_PROXIES)) continue;
				
				bProxyBoss = true;
				break;
			}
			
			if (bProxyBoss)
			{
				int iAlivePlayer = 0;
				for (int client = 1; client <= MaxClients; client++)
				{
					if (IsClientInGame(client) && IsPlayerAlive(client) && !g_PlayerEliminated[client])
					{
						iAlivePlayer++;
					}
				}
				
				if (iAlivePlayer >= (GetMaxPlayersForRound() / 2)) //Too many players are still alive... enter rage mode!
				{
					g_InProxySurvivalRageMode = true;
					EmitSoundToAll(PROXY_RAGE_MODE_SOUND);
					EmitSoundToAll(PROXY_RAGE_MODE_SOUND);
				}
			}
		}
	}
	
	int hours, minutes, seconds;
	FloatToTimeHMS(float(g_RoundTime), hours, minutes, seconds);
	
	SetHudTextParams(-1.0, 0.1, 
		1.0, 
		SF2_HUD_TEXT_COLOR_R, 
		SF2_HUD_TEXT_COLOR_G, 
		SF2_HUD_TEXT_COLOR_B, 
		SF2_HUD_TEXT_COLOR_A, 
		_, 
		_, 
		1.5, 1.5);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || (g_PlayerEliminated[i] && !IsClientInGhostMode(i))) continue;

		char sText[512];
		if (SF_IsBoxingMap())
			FormatEx(sText, sizeof(sText), "%T", "SF2 Default Boxing Message", i);
		else
		{
			if (SF_IsSurvivalMap() && g_RoundTime > g_iTimeEscape)
				FormatEx(sText, sizeof(sText), "%T", "SF2 Default Survive Message", i);
			else
				FormatEx(sText, sizeof(sText), "%T", "SF2 Default Escape Message", i);
		}
			
		char sTimerText[128];
		if (SF_SpecialRound(SPECIALROUND_EYESONTHECLOACK))
			strcopy(sTimerText, sizeof(sTimerText), "\n??:??");
		else
			FormatEx(sTimerText, sizeof(sTimerText), "\n%d:%02d", minutes, seconds);
			
		StrCat(sText, sizeof(sText), sTimerText);
			
		ShowSyncHudText(i, g_RoundTimerSync, sText);
	}
	if (g_IsSpecialRound)
		g_iSpecialRoundTime++;
	
	if (!g_bRoundTimerPaused)
	{
		SetRoundTime(g_RoundTime - 1);
	}
	
	return Plugin_Continue;
}

public Action Timer_VoteDifficulty(Handle timer, any data)
{
	ArrayList hArrayClients = view_as<ArrayList>(data);
	#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been created for hArrayClients in Timer_VoteDifficulty.", hArrayClients);
	#endif
	
	if (timer != g_hVoteTimer || IsRoundEnding())
	{
		delete hArrayClients;
		return Plugin_Stop;
	}
	
	if (IsVoteInProgress()) return Plugin_Continue; // There's another vote in progess. Wait.
	
	int iClients[MAXPLAYERS + 1] = { -1, ... };
	int iClientsNum;
	for (int i = 0, iSize = hArrayClients.Length; i < iSize; i++)
	{
		int client = GetClientOfUserId(hArrayClients.Get(i));
		if (client <= 0) continue;
		
		iClients[iClientsNum] = client;
		iClientsNum++;
	}
	
	delete hArrayClients;
	#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Array list %b has been deleted for hArrayClients in Timer_VoteDifficulty.", hArrayClients);
	#endif
	
	RandomizeVoteMenu();
	VoteMenu(g_MenuVoteDifficulty, iClients, iClientsNum, 15);
	
	return Plugin_Stop;
}

void SF_FailRoundEnd(float time = 2.0)
{
	//Check round win conditions again.
	CreateTimer((time - 0.8), Timer_CheckRoundWinConditions, _, TIMER_FLAG_NO_MAPCHANGE);
	
	if (!g_IgnoreRoundWinConditionsConVar.BoolValue)
	{
		g_TimerFail = CreateTimer(time, Timer_Fail, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

void SF_FailEnd()
{
	if (g_TimerFail != null)
		KillTimer(g_TimerFail);
	g_TimerFail = null;
}

public Action Timer_Fail(Handle hTimer)
{
	LogSF2Message("Wow you hit a rare bug, where the round doesn't end after the timer ran out. Collecting info on your game...\nContact Mentrillum or The Gaben and give them the following log:");
	int iEscapedPlayers = 0;
	int iClientInGame = 0;
	int iRedPlayers = 0;
	int iBluPlayers = 0;
	int iEliminatedPlayers = 0;
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			iClientInGame++;
			LogSF2Message("Player %N (%i), Team: %d, Eliminated: %d, Escaped: %d.", client, client, GetClientTeam(client), g_PlayerEliminated[client], DidClientEscape(client));
			if (GetClientTeam(client) == TFTeam_Blue)
				iBluPlayers++;
			else if (GetClientTeam(client) == TFTeam_Red)
				iRedPlayers++;
		}
		if (g_PlayerEliminated[client])
		{
			iEliminatedPlayers++;
		}
		if (DidClientEscape(client))
		{
			iEscapedPlayers++;
		}
	}
	LogSF2Message("Total clients: %d, Blu players: %d, Red players: %d, Escaped players: %d, Eliminated players: %d", MaxClients, iBluPlayers, iRedPlayers, iEscapedPlayers, iEliminatedPlayers);
	//Force blus to win.
	ForceTeamWin(TFTeam_Blue);
	
	g_TimerFail = null;
	
	return Plugin_Stop;
}

/**
 *	Initialize pages and entities.
 */
static void InitializeMapEntities()
{
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("START InitializeMapEntities()");
	#endif
	
	g_IsSurvivalMap = false;
	g_IsBoxingMap = false;
	g_IsRenevantMap = false;
	g_IsSlaughterRunMap = false;
	g_IsRaidMap = false;
	g_IsProxyMap = false;
	
	SF2GamerulesEntity gamerules = FindSF2GamerulesEntity();
	g_GamerulesEntity = gamerules;
	
	if (gamerules.IsValid())
	{
		if (g_iRoundActiveCount == 1)
			g_MaxPlayersConVar.SetInt(gamerules.MaxPlayers);
		
		char sBossName[SF2_MAX_PROFILE_NAME_LENGTH];
		gamerules.GetBossName(sBossName, sizeof(sBossName));
		if (sBossName[0] != '\0')g_BossMainConVar.SetString(sBossName);
		
		g_PageMax = gamerules.MaxPages;
		
		g_RoundTimeLimit = gamerules.InitialTimeLimit;
		g_RoundTimeGainFromPage = gamerules.PageCollectAddTime;
		
		gamerules.GetPageCollectSoundPath(g_strPageCollectSound, sizeof(g_strPageCollectSound));
		if (g_strPageCollectSound[0] == '\0')
			strcopy(g_strPageCollectSound, sizeof(g_strPageCollectSound), PAGE_GRABSOUND); // Roll with default instead.
		
		g_iPageSoundPitch = gamerules.PageCollectSoundPitch;
		
		g_bRoundHasEscapeObjective = gamerules.HasEscapeObjective;
		g_RoundEscapeTimeLimit = gamerules.EscapeTimeLimit;
		g_RoundStopPageMusicOnEscape = gamerules.StopPageMusicOnEscape;
		g_IsSurvivalMap = gamerules.Survive;
		g_iTimeEscape = gamerules.SurviveUntilTime;
		
		g_bRoundInfiniteFlashlight = gamerules.InfiniteFlashlight;
		g_IsRoundInfiniteSprint = gamerules.InfiniteSprint;
		g_bRoundInfiniteBlink = gamerules.InfiniteBlink;
		
		g_BossesChaseEndlessly = gamerules.BossesChaseEndlessly;
		
		gamerules.GetIntroMusicPath(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic));
		if (g_strRoundIntroMusic[0] == '\0')
			strcopy(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic), SF2_INTRO_DEFAULT_MUSIC); // Roll with default instead.
		
		gamerules.GetIntroFadeColor(g_iRoundIntroFadeColor);
		g_flRoundIntroFadeHoldTime = gamerules.IntroFadeHoldTime;
		g_flRoundIntroFadeDuration = gamerules.IntroFadeTime;
	}
	else
	{
		g_RoundTimeLimit = g_TimeLimitConVar.IntValue;
		g_RoundTimeGainFromPage = g_TimeGainFromPageGrabConVar.IntValue;
		strcopy(g_strPageCollectSound, sizeof(g_strPageCollectSound), PAGE_GRABSOUND);
		g_iPageSoundPitch = 100;
		
		g_bRoundHasEscapeObjective = false;
		g_RoundEscapeTimeLimit = g_TimeLimitEscapeConVar.IntValue;
		g_RoundStopPageMusicOnEscape = false;
		g_iTimeEscape = g_TimeEscapeSurvivalConVar.IntValue;
		
		g_bRoundInfiniteFlashlight = false;
		g_IsRoundInfiniteSprint = false;
		g_bRoundInfiniteBlink = false;
		
		g_BossesChaseEndlessly = false;
		
		strcopy(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic), SF2_INTRO_DEFAULT_MUSIC);
		
		g_iRoundIntroFadeColor[0] = 0;
		g_iRoundIntroFadeColor[1] = 0;
		g_iRoundIntroFadeColor[2] = 0;
		g_iRoundIntroFadeColor[3] = 255;
		g_flRoundIntroFadeHoldTime = g_IntroDefaultHoldTimeConVar.FloatValue;
		g_flRoundIntroFadeDuration = g_IntroDefaultFadeTimeConVar.FloatValue;
	}
	
	// Check the game type.
	if (FindLogicProxyEntity().IsValid())
	{
		g_IsProxyMap = true;
		g_IsSurvivalMap = true;
	}
	else if (FindLogicRaidEntity().IsValid())
	{
		g_IsRaidMap = true;
	}
	else if (FindLogicBoxingEntity().IsValid())
	{
		g_IsBoxingMap = true;
	}
	else if (FindLogicSlaughterEntity().IsValid())
	{
		g_IsSlaughterRunMap = true;
	}
	else if ((g_RenevantLogicEntity = FindLogicRenevantEntity()).IsValid())
	{
		g_IsRenevantMap = true;
	}
	
	if (SF_IsRenevantMap())
	{
		if (g_RenevantLogicEntity.IsValid())
		{
			g_RenevantFinaleTime = g_RenevantLogicEntity.FinaleTime;
		}
		else
		{
			g_RenevantFinaleTime = 60;
		}
	}
	
	char targetName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0])
		{
			if (!StrContains(targetName, "sf2_maxpages_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_maxpages_", "", false);
				g_PageMax = StringToInt(targetName);
			}
			else if (!StrContains(targetName, "sf2_logic_escape", false))
			{
				g_bRoundHasEscapeObjective = true;
			}
			else if (strcmp(targetName, "sf2_escape_custommusic", false) == 0)
			{
				g_RoundStopPageMusicOnEscape = true;
			}
			else if (!StrContains(targetName, "sf2_infiniteflashlight", false))
			{
				g_bRoundInfiniteFlashlight = true;
			}
			else if (!StrContains(targetName, "sf2_infiniteblink", false))
			{
				g_bRoundInfiniteBlink = true;
			}
			else if (!StrContains(targetName, "sf2_infinitesprint", false))
			{
				g_IsRoundInfiniteSprint = true;
			}
			else if (!StrContains(targetName, "sf2_time_limit_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_time_limit_", "", false);
				g_RoundTimeLimit = StringToInt(targetName);
				
				LogSF2Message("Found sf2_time_limit entity, set time limit to %d", g_RoundTimeLimit);
			}
			else if (!StrContains(targetName, "sf2_escape_time_limit_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_escape_time_limit_", "", false);
				g_RoundEscapeTimeLimit = StringToInt(targetName);
				
				LogSF2Message("Found sf2_escape_time_limit entity, set escape time limit to %d", g_RoundEscapeTimeLimit);
			}
			else if (!StrContains(targetName, "sf2_time_gain_from_page_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_time_gain_from_page_", "", false);
				g_RoundTimeGainFromPage = StringToInt(targetName);
				
				LogSF2Message("Found sf2_time_gain_from_page entity, set time gain to %d", g_RoundTimeGainFromPage);
			}
			else if (g_iRoundActiveCount == 1 && (!StrContains(targetName, "sf2_maxplayers_", false)))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_maxplayers_", "", false);
				g_MaxPlayersConVar.SetInt(StringToInt(targetName));
				
				LogSF2Message("Found sf2_maxplayers entity, set maxplayers to %d", StringToInt(targetName));
			}
			else if (!StrContains(targetName, "sf2_boss_override_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_boss_override_", "", false);
				g_BossMainConVar.SetString(targetName);
				
				LogSF2Message("Found sf2_boss_override entity, set boss profile override to %s", targetName);
			}
			else if (!StrContains(targetName, "sf2_survival_map", false))
			{
				g_IsSurvivalMap = true;
			}
			else if (!StrContains(targetName, "sf2_raid_map", false))
			{
				g_IsRaidMap = true;
			}
			else if (!StrContains(targetName, "sf2_bosses_chase_endlessly", false))
			{
				g_BossesChaseEndlessly = true;
			}
			else if (!StrContains(targetName, "sf2_proxy_map", false))
			{
				g_IsProxyMap = true;
				g_IsSurvivalMap = true;
			}
			else if (!StrContains(targetName, "sf2_boxing_map", false))
			{
				g_IsBoxingMap = true;
			}
			else if (!StrContains(targetName, "sf2_survival_time_limit_", false))
			{
				ReplaceString(targetName, sizeof(targetName), "sf2_survival_time_limit_", "", false);
				g_iTimeEscape = StringToInt(targetName);
				
				LogSF2Message("Found sf2_survival_time_limit_ entity, set survival time limit to %d", g_iTimeEscape);
			}
			else if (!StrContains(targetName, "sf2_renevant_map", false))
			{
				g_IsRenevantMap = true;
			}
			else if (!StrContains(targetName, "sf2_slaughterrun_map", false))
			{
				g_IsSlaughterRunMap = true;
			}
		}
	}
	
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "ambient_generic")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0] == '\0')
			continue;
		
		if (strcmp(targetName, "sf2_page_sound", false) == 0)
		{
			char sPagePath[PLATFORM_MAX_PATH];
			GetEntPropString(ent, Prop_Data, "m_iszSound", sPagePath, sizeof(sPagePath));
			
			if (sPagePath[0] == '\0')
			{
				LogError("Found sf2_page_sound entity, but it has no sound path specified! Default page sound will be used instead.");
			}
			else
			{
				strcopy(g_strPageCollectSound, sizeof(g_strPageCollectSound), sPagePath);
			}
		}
	}
	
	// For old page spawn points, get the reference entity if it exists.
	g_PageRef = false;
	strcopy(g_PageRefModelName, sizeof(g_PageRefModelName), PAGE_MODEL);
	g_PageRefModelScale = 1.0;
	
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "prop_dynamic")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0] == '\0')
			continue;
		
		if (strcmp(targetName, "sf2_page_model", false) == 0)
		{
			g_PageRef = true;
			GetEntPropString(ent, Prop_Data, "m_ModelName", g_PageRefModelName, sizeof(g_PageRefModelName));
			g_PageRefModelScale = GetEntPropFloat(ent, Prop_Send, "m_flModelScale");
			break;
		}
	}
	
	#if defined DEBUG
	LogSF2Message("ROUND SETTINGS:\n - Time limit: %i\n - Time gain from page: %i\n - Page collect sound: %s\n - Escape?: %i\n - Escape time limit: %i\n - Stop page music on escape: %i\n - Survive before escape?: %i\n - Survive until time: %i\n - Infinite flashlight: %i\n - Infinite sprint: %i\n - Infinite blink: %i\n - Bosses chase endlessly: %i\n - Intro music: %s\n - Intro fade hold time: %f\n - Intro fade time: %f", 
		g_RoundTimeLimit, g_RoundTimeGainFromPage, g_strPageCollectSound, g_bRoundHasEscapeObjective, g_RoundEscapeTimeLimit, g_RoundStopPageMusicOnEscape, g_IsSurvivalMap, g_iTimeEscape, g_bRoundInfiniteFlashlight, g_IsRoundInfiniteSprint, g_bRoundInfiniteBlink, g_BossesChaseEndlessly, g_strRoundIntroMusic, g_flRoundIntroFadeHoldTime, g_flRoundIntroFadeDuration);
	#endif
	
	GetRoundIntroParameters();
	GetRoundEscapeParameters();
	GetPageMusicRanges();
	SpawnPages();
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("END InitializeMapEntities()");
	#endif
}

void SpawnPages()
{
	g_Pages.Clear();
	
	ArrayList hArray = new ArrayList(2);
	StringMap hPageGroupsByName = new StringMap();
	
	ArrayList hPageSpawnPoints = new ArrayList();
	
	int ent = -1;
	char targetName[64];
	
	// Collect all possible page spawn points.
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", targetName, sizeof(targetName));
		if (targetName[0])
		{
			if (!StrContains(targetName, "sf2_page_spawnpoint", false))
			{
				hPageSpawnPoints.Push(EnsureEntRef(ent));
			}
		}
	}
	
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "sf2_info_page_spawn")) != -1)
	{
		SF2PageSpawnEntity pageSpawn = SF2PageSpawnEntity(ent);
		if (pageSpawn.IsValid())
		{
			hPageSpawnPoints.Push(EnsureEntRef(ent));
		}
	}
	
	if (hPageSpawnPoints.Length > 0)
	{
		// Try to sort spawn points into their respective groups.
		
		char sPageGroup[64];
		
		for (int i = 0; i < hPageSpawnPoints.Length; i++)
		{
			int iSpawnPoint = hPageSpawnPoints.Get(i);
			if (!IsValidEntity(iSpawnPoint))
				continue;
			
			// Get page group if possible.
			SF2PageSpawnEntity pageSpawn = SF2PageSpawnEntity(iSpawnPoint);
			if (pageSpawn.IsValid())
			{
				pageSpawn.GetPageGroup(sPageGroup, sizeof(sPageGroup));
			}
			else
			{
				GetEntPropString(iSpawnPoint, Prop_Data, "m_iName", sPageGroup, sizeof(sPageGroup));
				
				if (!StrContains(sPageGroup, "sf2_page_spawnpoint_", false))
					ReplaceString(sPageGroup, sizeof(sPageGroup), "sf2_page_spawnpoint_", "", false);
				else
					sPageGroup[0] = '\0';
			}
			
			if (sPageGroup[0] != '\0')
			{
				// Spawn point belongs to a group.
				
				ArrayList hButtStallion;
				if (!hPageGroupsByName.GetValue(sPageGroup, hButtStallion))
				{
					// Initialize new page group since it didn't exist.
					hButtStallion = new ArrayList();
					hPageGroupsByName.SetValue(sPageGroup, hButtStallion);
					
					int iIndex = hArray.Push(hButtStallion);
					hArray.Set(iIndex, true, 1);
				}
				
				hButtStallion.Push(EnsureEntRef(iSpawnPoint));
			}
			else
			{
				int iIndex = hArray.Push(EnsureEntRef(iSpawnPoint));
				hArray.Set(iIndex, false, 1);
			}
		}
	}
	
	delete hPageSpawnPoints;
	
	int iPageCount = hArray.Length;
	if (iPageCount)
	{
		// Spawn all pages.
		hArray.Sort(Sort_Random, Sort_Integer);
		
		float vecPos[3], vecAng[3];
	
		char sPageModel[PLATFORM_MAX_PATH];
		char sPageParentName[64];
		float flPageModelScale;
		int iPageSkin;
		RenderFx iPageRenderFx;
		RenderMode iPageRenderMode;
		int iPageBodygroup;
		int iPageRenderColor[4];
		char sPageAnimation[64];
		
		for (int i = 0; i < iPageCount && (i + 1) <= g_PageMax; i++)
		{
			int iSpawnPoint = -1;
			if (view_as<bool>(hArray.Get(i, 1)))
			{
				ArrayList hButtStallion = view_as<ArrayList>(hArray.Get(i));
				iSpawnPoint = hButtStallion.Get(GetRandomInt(0, hButtStallion.Length - 1));
			}
			else
			{
				iSpawnPoint = hArray.Get(i);
			}
			
			SF2PageSpawnEntity spawnPoint = SF2PageSpawnEntity(iSpawnPoint);
			
			GetEntPropVector(iSpawnPoint, Prop_Data, "m_vecAbsOrigin", vecPos);
			GetEntPropVector(iSpawnPoint, Prop_Data, "m_angAbsRotation", vecAng);
			GetEntPropString(iSpawnPoint, Prop_Data, "m_iParent", sPageParentName, sizeof(sPageParentName));
			
			// Get model, scale, skin, and animation.
			if (spawnPoint.IsValid())
			{
				spawnPoint.GetPageModel(sPageModel, sizeof(sPageModel));
				flPageModelScale = spawnPoint.PageModelScale;
				iPageSkin = spawnPoint.PageSkin == -1 ? i : spawnPoint.PageSkin;
				iPageBodygroup = spawnPoint.PageBodygroup;
				iPageRenderFx = spawnPoint.GetRenderFx();
				iPageRenderMode = spawnPoint.GetRenderMode();
				spawnPoint.GetRenderColor(iPageRenderColor[0], iPageRenderColor[1], iPageRenderColor[2], iPageRenderColor[3]);
				spawnPoint.GetPageAnimation(sPageAnimation, sizeof(sPageAnimation));
			}
			else if (g_PageRef)
			{
				strcopy(sPageModel, sizeof(sPageModel), g_PageRefModelName);
				flPageModelScale = g_PageRefModelScale;
				iPageSkin = i;
				iPageBodygroup = 0;
				iPageRenderFx = RENDERFX_NONE;
				iPageRenderMode = RENDER_NORMAL;
				iPageRenderColor[0] = 255; iPageRenderColor[1] = 255; iPageRenderColor[2] = 255; iPageRenderColor[3] = 255;
				sPageAnimation[0] = '\0';
			}
			else
			{
				strcopy(sPageModel, sizeof(sPageModel), PAGE_MODEL);
				flPageModelScale = PAGE_MODELSCALE;
				iPageSkin = i;
				iPageBodygroup = 0;
				iPageRenderFx = RENDERFX_NONE;
				iPageRenderMode = RENDER_NORMAL;
				iPageRenderColor[0] = 255; iPageRenderColor[1] = 255; iPageRenderColor[2] = 255; iPageRenderColor[3] = 255;
				sPageAnimation[0] = '\0';
			}
			
			// Create fake page model
			char pageName[50];
			int page2 = CreateEntityByName("prop_dynamic_override");
			if (page2 != -1)
			{
				DispatchKeyValue(page2, "targetname", "sf2_page_ex");
				DispatchKeyValue(page2, "parentname", sPageParentName);
				DispatchKeyValue(page2, "solid", "0");
				SetEntityModel(page2, sPageModel);
				TeleportEntity(page2, vecPos, vecAng, NULL_VECTOR);
				DispatchSpawn(page2);
				ActivateEntity(page2);
				SetVariantInt(iPageSkin);
				AcceptEntityInput(page2, "Skin");
				SetVariantInt(iPageBodygroup);
				AcceptEntityInput(page2, "SetBodyGroup");
				AcceptEntityInput(page2, "DisableCollision");
				SetEntPropFloat(page2, Prop_Send, "m_flModelScale", flPageModelScale);
				SetEntityFlags(page2, GetEntityFlags(page2) | FL_EDICT_ALWAYS);
				SetEntityRenderMode(page2, iPageRenderMode);
				SetEntityRenderFx(page2, iPageRenderFx);
				SetEntityRenderColor(page2, iPageRenderColor[0], iPageRenderColor[1], iPageRenderColor[2], iPageRenderColor[3]);
				
				CreateTimer(1.0, Page_RemoveAlwaysTransmit, EntIndexToEntRef(page2), TIMER_FLAG_NO_MAPCHANGE);
				SDKHook(page2, SDKHook_SetTransmit, Hook_SlenderObjectSetTransmitEx);
				
				if (sPageAnimation[0] != '\0')
				{
					SetVariantString(sPageAnimation);
					AcceptEntityInput(page2, "SetDefaultAnimation");
					SetVariantString(sPageAnimation);
					AcceptEntityInput(page2, "SetAnimation");
				}
			}
			
			// Create actual page entity
			int page = CreateEntityByName("prop_dynamic_override");
			if (page != -1)
			{
				FormatEx(pageName, sizeof(pageName), "sf2_page_ex_%d", i);
				DispatchKeyValue(page, "targetname", pageName);
				DispatchKeyValue(page, "parentname", sPageParentName);
				DispatchKeyValue(page, "solid", "2");
				SetEntityModel(page, sPageModel);
				TeleportEntity(page, vecPos, vecAng, NULL_VECTOR);
				DispatchSpawn(page);
				ActivateEntity(page);
				SetVariantInt(iPageSkin);
				AcceptEntityInput(page, "Skin");
				SetVariantInt(iPageBodygroup);
				AcceptEntityInput(page, "SetBodyGroup");
				AcceptEntityInput(page, "EnableCollision");
				SetEntPropFloat(page, Prop_Send, "m_flModelScale", flPageModelScale);
				SetEntPropEnt(page, Prop_Send, "m_hOwnerEntity", page2);
				SetEntPropEnt(page, Prop_Send, "m_hEffectEntity", page2);
				SetEntProp(page, Prop_Send, "m_fEffects", EF_ITEM_BLINK);
				SetEntityFlags(page, GetEntityFlags(page) | FL_EDICT_ALWAYS);
				SetEntityRenderMode(page, iPageRenderMode);
				SetEntityRenderFx(page, iPageRenderFx);
				SetEntityRenderColor(page, iPageRenderColor[0], iPageRenderColor[1], iPageRenderColor[2], iPageRenderColor[3]);
				
				CreateTimer(1.0, Page_RemoveAlwaysTransmit, EntIndexToEntRef(page), TIMER_FLAG_NO_MAPCHANGE);
				SDKHook(page, SDKHook_OnTakeDamage, Hook_PageOnTakeDamage);
				SDKHook(page, SDKHook_SetTransmit, Hook_SlenderObjectSetTransmit);
				
				if (sPageAnimation[0] != '\0')
				{
					SetVariantString(sPageAnimation);
					AcceptEntityInput(page, "SetDefaultAnimation");
					SetVariantString(sPageAnimation);
					AcceptEntityInput(page, "SetAnimation");
				}
				
				SF2PageEntityData pageData;
				pageData.EntRef = EnsureEntRef(page);
				
				if (spawnPoint.IsValid())
				{
					spawnPoint.GetPageCollectSound(pageData.CollectSound, PLATFORM_MAX_PATH);
					pageData.CollectSoundPitch = spawnPoint.PageCollectSoundPitch;
				}
				else
				{
					pageData.CollectSound[0] = '\0';
					pageData.CollectSoundPitch = 0;
				}
				
				g_Pages.PushArray(pageData, sizeof(pageData));
			}
		}
		
		// Safely remove all handles.
		for (int i = 0, iSize = hArray.Length; i < iSize; i++)
		{
			if (view_as<bool>(hArray.Get(i, 1)))
			{
				delete view_as<ArrayList>(hArray.Get(i));
			}
		}
		
		Call_StartForward(g_OnPagesSpawnedFwd);
		Call_Finish();
	}
	
	delete hPageGroupsByName;
	delete hArray;
}

public Action Page_RemoveAlwaysTransmit(Handle timer, int iRef)
{
	int iPage = EntRefToEntIndex(iRef);
	if (iPage > MaxClients && IsValidEdict(iPage))
	{
		//All the pages are now "registred" by the client, nuke the always transmit flag.
		SetEntityFlags(iPage, GetEntityFlags(iPage) ^ FL_EDICT_ALWAYS);
	}
	return Plugin_Stop;
}
static bool HandleSpecialRoundState()
{
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("START HandleSpecialRoundState()");
	#endif
	
	bool bOld = g_IsSpecialRound;
	bool bContinuousOld = g_IsSpecialRoundContinuous;
	g_IsSpecialRound = false;
	g_IsSpecialRoundNew = false;
	g_IsSpecialRoundContinuous = false;
	
	bool bForceNew = false;
	
	if (bOld)
	{
		if (bContinuousOld)
		{
			// Check if there are players who haven't played the special round yet.
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsClientParticipating(i))
				{
					g_bPlayerPlayedSpecialRound[i] = true;
					continue;
				}
				
				if (!g_bPlayerPlayedSpecialRound[i])
				{
					// Someone didn't get to play this yet. Continue the special round.
					g_IsSpecialRound = true;
					g_IsSpecialRoundContinuous = true;
					break;
				}
			}
		}
	}
	
	int iRoundInterval = g_SpecialRoundIntervalConVar.IntValue;
	
	if (iRoundInterval > 0 && g_iSpecialRoundCount >= iRoundInterval)
	{
		g_IsSpecialRound = true;
		bForceNew = true;
	}
	
	// Do special round force override and reset it.
	if (g_SpecialRoundForceConVar.IntValue >= 0)
	{
		g_IsSpecialRound = g_SpecialRoundForceConVar.BoolValue;
		g_SpecialRoundForceConVar.SetInt(-1);
	}
	
	if (g_IsSpecialRound)
	{
		if (bForceNew || !bOld || !bContinuousOld)
		{
			g_IsSpecialRoundNew = true;
		}
		
		if (g_IsSpecialRoundNew)
		{
			if (g_SpecialRoundBehaviorConVar.IntValue == 1)
			{
				g_IsSpecialRoundContinuous = true;
			}
			else
			{
				// new special round, but it's not continuous.
				g_IsSpecialRoundContinuous = false;
			}
		}
	}
	else
	{
		g_IsSpecialRoundContinuous = false;
	}
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0)DebugMessage("END HandleSpecialRoundState() -> g_IsSpecialRound = %d (count = %d, new = %d, continuous = %d)", g_IsSpecialRound, g_iSpecialRoundCount, g_IsSpecialRoundNew, g_IsSpecialRoundContinuous);
	#endif
}
/*
bool IsNewBossRoundRunning()
{
	return g_bNewBossRound;
}
*/
/**
 *	Returns an array which contains all the profile names valid to be chosen for a new boss round.
 */
static ArrayList GetNewBossRoundProfileList()
{
	ArrayList hBossList = GetSelectableBossProfileQueueList().Clone();

	#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Clone array list %b has been created for hBossList in GetNewBossRoundProfileList.", hBossList);
	#endif
	
	if (hBossList.Length > 0)
	{
		char sMainBoss[SF2_MAX_PROFILE_NAME_LENGTH];
		g_BossMainConVar.GetString(sMainBoss, sizeof(sMainBoss));
		
		int index = hBossList.FindString(sMainBoss);
		if (index != -1)
		{
			// Main boss exists; remove him from the list.
			hBossList.Erase(index);
		}
		/*else
		{
			// Main boss doesn't exist; remove the first boss from the list.
			hBossList.Erase(0);
		}*/
	}
	
	return hBossList;
}

static void HandleNewBossRoundState()
{
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("START HandleNewBossRoundState()");
	#endif
	
	bool bOld = g_bNewBossRound;
	bool bContinuousOld = g_bNewBossRoundContinuous;
	g_bNewBossRound = false;
	g_bNewBossRoundNew = false;
	g_bNewBossRoundContinuous = false;
	
	bool bForceNew = false;
	
	if (bOld)
	{
		if (bContinuousOld)
		{
			// Check if there are players who haven't played the boss round yet.
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsClientParticipating(i))
				{
					g_bPlayerPlayedNewBossRound[i] = true;
					continue;
				}
				
				if (!g_bPlayerPlayedNewBossRound[i])
				{
					// Someone didn't get to play this yet. Continue the boss round.
					g_bNewBossRound = true;
					g_bNewBossRoundContinuous = true;
					break;
				}
			}
		}
	}
	
	// Don't force a new special round while a continuous round is going on.
	if (!g_bNewBossRoundContinuous)
	{
		int iRoundInterval = g_NewBossRoundIntervalConVar.IntValue;
		
		if (/*iRoundInterval > 0 &&*/iRoundInterval <= 0 || g_iNewBossRoundCount >= iRoundInterval)
		{
			g_bNewBossRound = true;
			bForceNew = true;
		}
	}
	
	// Do boss round force override and reset it.
	if (g_NewBossRoundForceConVar.IntValue >= 0)
	{
		g_bNewBossRound = g_NewBossRoundForceConVar.BoolValue;
		g_NewBossRoundForceConVar.SetInt(-1);
	}
	
	// Check if we have enough bosses.
	if (g_bNewBossRound)
	{
		ArrayList hBossList = GetNewBossRoundProfileList().Clone();
		
		if (hBossList.Length < 1)
		{
			g_bNewBossRound = false; // Not enough bosses.
		}
		
		delete hBossList;

		#if defined DEBUG
		SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Clone array list %b has been deleted for hBossList in HandleNewBossRoundState which comes from GetNewBossRoundProfileList.", hBossList);
		#endif
	}
	
	if (g_bNewBossRound)
	{
		if (bForceNew || !bOld || !bContinuousOld)
		{
			g_bNewBossRoundNew = true;
		}
		
		if (g_bNewBossRoundNew)
		{
			if (g_NewBossRoundBehaviorConVar.IntValue == 1)
			{
				g_bNewBossRoundContinuous = true;
			}
			else
			{
				// new "new boss round", but it's not continuous.
				g_bNewBossRoundContinuous = false;
			}
		}
	}
	else
	{
		g_bNewBossRoundContinuous = false;
	}
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("END HandleintBossRoundState() -> g_bNewBossRound = %d (count = %d, int = %d, continuous = %d)", g_bNewBossRound, g_iNewBossRoundCount, g_bNewBossRoundNew, g_bNewBossRoundContinuous);
	#endif
}

/**
 *	Returns the amount of players that are in game and currently not eliminated.
 */
int GetActivePlayerCount()
{
	int count = 0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsClientParticipating(i)) continue;
		
		if (!g_PlayerEliminated[i])
		{
			count++;
		}
	}
	
	return count;
}

static void SelectStartingBossesForRound()
{
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("START SelectStartingBossesForRound()");
	#endif
	
	ArrayList hSelectableBossList = GetSelectableBossProfileQueueList().Clone();

	#if defined DEBUG
	SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Clone array list %b has been created for hSelectableBossList in SelectStartingBossesForRound.", hSelectableBossList);
	#endif
	
	// Select which boss profile to use.
	char sProfileOverride[SF2_MAX_PROFILE_NAME_LENGTH];
	g_BossProfileOverrideConVar.GetString(sProfileOverride, sizeof(sProfileOverride));
	
	if (!SF_IsBoxingMap())
	{
		if (sProfileOverride[0] != '\0' && IsProfileValid(sProfileOverride))
		{
			// Pick the overridden boss.
			strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), sProfileOverride);
			g_BossProfileOverrideConVar.SetString("");
		}
		else if (g_bNewBossRound)
		{
			if (g_bNewBossRoundNew)
			{
				ArrayList hBossList = GetNewBossRoundProfileList();
				
				hBossList.GetString(GetRandomInt(0, hBossList.Length - 1), g_strNewBossRoundProfile, sizeof(g_strNewBossRoundProfile));
				
				delete hBossList;

				#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Clone array list %b has been deleted for hBossList in SelectStartingBossesForRound which comes from GetNewBossRoundProfileList.", hBossList);
				#endif
			}
			
			strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), g_strNewBossRoundProfile);
		}
		else
		{
			char profile[SF2_MAX_PROFILE_NAME_LENGTH];
			g_BossMainConVar.GetString(profile, sizeof(profile));
			
			if (profile[0] != '\0' && IsProfileValid(profile))
			{
				strcopy(g_strRoundBossProfile, sizeof(g_strRoundBossProfile), profile);
			}
			else
			{
				if (hSelectableBossList.Length > 0)
				{
					// Pick the first boss in our array if the main boss doesn't exist.
					hSelectableBossList.GetString(0, g_strRoundBossProfile, sizeof(g_strRoundBossProfile));
				}
				else
				{
					// No bosses to pick. What?
					g_strRoundBossProfile[0] = '\0';
				}
			}
		}
		
		#if defined DEBUG
		if (g_DebugDetailConVar.IntValue > 0) DebugMessage("END SelectStartingBossesForRound() -> boss: %s", g_strRoundBossProfile);
		#endif
	}
	else if (SF_IsBoxingMap())
	{
		if (sProfileOverride[0] != '\0' && IsProfileValid(sProfileOverride))
		{
			// Pick the overridden boss.
			strcopy(g_strRoundBoxingBossProfile, sizeof(g_strRoundBoxingBossProfile), sProfileOverride);
			g_BossProfileOverrideConVar.SetString("");
		}
		else if (g_bNewBossRound)
		{
			if (g_bNewBossRoundNew)
			{
				ArrayList hBossList = GetNewBossRoundProfileList();
				
				hBossList.GetString(GetRandomInt(0, hBossList.Length - 1), g_strNewBossRoundProfile, sizeof(g_strNewBossRoundProfile));
				
				delete hBossList;

				#if defined DEBUG
				SendDebugMessageToPlayers(DEBUG_ARRAYLIST, 0, "Clone array list %b has been deleted for hBossList in SelectStartingBossesForRound which comes from GetNewBossRoundProfileList.", hBossList);
				#endif
			}
			
			strcopy(g_strRoundBoxingBossProfile, sizeof(g_strRoundBoxingBossProfile), g_strNewBossRoundProfile);
		}
		else
		{
			char profile[SF2_MAX_PROFILE_NAME_LENGTH];
			g_BossMainConVar.GetString(profile, sizeof(profile));
			
			if (profile[0] != '\0' && IsProfileValid(profile))
			{
				strcopy(g_strRoundBoxingBossProfile, sizeof(g_strRoundBoxingBossProfile), profile);
			}
			else
			{
				if (hSelectableBossList.Length > 0)
				{
					// Pick the first boss in our array if the main boss doesn't exist.
					hSelectableBossList.GetString(0, g_strRoundBoxingBossProfile, sizeof(g_strRoundBoxingBossProfile));
				}
				else
				{
					// No bosses to pick. What?
					g_strRoundBoxingBossProfile[0] = '\0';
				}
			}
		}
		
		#if defined DEBUG
		if (g_DebugDetailConVar.IntValue > 0) DebugMessage("END SelectStartingBossesForRound() -> boss: %s", g_strRoundBoxingBossProfile);
		#endif
	}
	delete hSelectableBossList;
}

static void GetRoundIntroParameters()
{
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "env_fade")) != -1)
	{
		char sName[32];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (strcmp(sName, "sf2_intro_fade", false) == 0)
		{
			int iColorOffset = FindSendPropInfo("CBaseEntity", "m_clrRender");
			if (iColorOffset != -1)
			{
				g_iRoundIntroFadeColor[0] = GetEntData(ent, iColorOffset, 1);
				g_iRoundIntroFadeColor[1] = GetEntData(ent, iColorOffset + 1, 1);
				g_iRoundIntroFadeColor[2] = GetEntData(ent, iColorOffset + 2, 1);
				g_iRoundIntroFadeColor[3] = GetEntData(ent, iColorOffset + 3, 1);
			}
			
			g_flRoundIntroFadeHoldTime = GetEntPropFloat(ent, Prop_Data, "m_HoldTime");
			g_flRoundIntroFadeDuration = GetEntPropFloat(ent, Prop_Data, "m_Duration");
			
			break;
		}
	}
	
	ent = -1;
	while ((ent = FindEntityByClassname(ent, "ambient_generic")) != -1)
	{
		char sName[64];
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		
		if (strcmp(sName, "sf2_intro_music", false) == 0)
		{
			char sSongPath[PLATFORM_MAX_PATH];
			GetEntPropString(ent, Prop_Data, "m_iszSound", sSongPath, sizeof(sSongPath));
			
			if (sSongPath[0] == '\0')
			{
				LogError("Found sf2_intro_music entity, but it has no sound path specified! Default intro music will be used instead.");
			}
			else
			{
				strcopy(g_strRoundIntroMusic, sizeof(g_strRoundIntroMusic), sSongPath);
			}
			
			break;
		}
	}
}

static void GetRoundEscapeParameters()
{
	g_iRoundEscapePointEntity = INVALID_ENT_REFERENCE;
	
	char sName[64];
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_target")) != -1)
	{
		GetEntPropString(ent, Prop_Data, "m_iName", sName, sizeof(sName));
		if (!StrContains(sName, "sf2_escape_spawnpoint", false))
		{
			g_iRoundEscapePointEntity = EntIndexToEntRef(ent);
			break;
		}
	}
}

void InitializeNewGame()
{
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("START InitializeNewGame()");
	#endif
	
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_regenerate")) != -1)
	{
		AcceptEntityInput(ent, "Enable");
	}
	
	InitializeMapEntities();
	
	//Tutorial_EnableHooks();
	
	if (SF_IsBoxingMap())
	{
		g_SlenderBoxingBossCount = 0;
		g_SlenderBoxingBossKilled = 0;
	}
	else if (SF_IsRenevantMap())
	{
		g_RenevantWaveTimer = null;
		g_RenevantMultiEffect = false;
		g_RenevantBeaconEffect = false;
		g_Renevant90sEffect = false;
		g_RenevantMarkForDeath = false;

		Renevant_SetWave(0);
	}

	if (g_RenevantWaveList != null)
	{
		delete g_RenevantWaveList;
	}
	
	// Choose round state.
	if (g_IntroEnabledConVar.BoolValue)
	{
		// Set the round state to the intro stage.
		SetRoundState(SF2RoundState_Intro);
	}
	else
	{
		SetRoundState(SF2RoundState_Grace);
		SF2_RefreshRestrictions();
	}
	
	if (g_iRoundActiveCount == 1)
	{
		g_BossProfileOverrideConVar.SetString("");
	}
	
	HandleSpecialRoundState();
	
	// Was a new special round initialized?
	if (g_IsSpecialRound && !SF_IsRenevantMap())
	{
		if (g_IsSpecialRoundNew)
		{
			// Reset round count.
			g_iSpecialRoundCount = 1;
			
			if (g_IsSpecialRoundContinuous)
			{
				// It's the start of a continuous special round.
				
				// Initialize all players' values.
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsClientParticipating(i))
					{
						g_bPlayerPlayedSpecialRound[i] = true;
						continue;
					}
					
					g_bPlayerPlayedSpecialRound[i] = false;
				}
			}
			
			SpecialRoundCycleStart();
		}
		else
		{
			SpecialRoundStart();
			
			if (g_IsSpecialRoundContinuous)
			{
				// Display the current special round going on to late players.
				CreateTimer(3.0, Timer_DisplaySpecialRound);
			}
		}
	}
	else
	{
		g_iSpecialRoundCount++;
		
		SpecialRoundReset();
	}
	
	// Determine boss round state.
	HandleNewBossRoundState();
	
	if (g_bNewBossRound)
	{
		if (g_bNewBossRoundNew)
		{
			// Reset round count;
			g_iNewBossRoundCount = 1;
			
			if (g_bNewBossRoundContinuous)
			{
				// It's the start of a continuous "new boss round".
				
				// Initialize all players' values.
				for (int i = 1; i <= MaxClients; i++)
				{
					if (!IsClientInGame(i) || !IsClientParticipating(i))
					{
						g_bPlayerPlayedNewBossRound[i] = true;
						continue;
					}
					
					g_bPlayerPlayedNewBossRound[i] = false;
				}
			}
		}
	}
	else
	{
		g_iNewBossRoundCount++;
	}
	
	SelectStartingBossesForRound();
	
	ForceInNextPlayersInQueue(GetMaxPlayersForRound());
	
	// Respawn all players, if needed.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientParticipating(i))
		{
			if (!HandlePlayerTeam(i))
			{
				if (!g_PlayerEliminated[i])
				{
					// Players currently in the "game" still have to be respawned.
					TF2_RespawnPlayer(i);
				}
			}
		}
	}
	
	if (GetRoundState() == SF2RoundState_Intro)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i)) continue;
			
			if (!g_PlayerEliminated[i])
			{
				if (!IsFakeClient(i))
				{
					// Currently in intro state, play intro music.
					g_PlayerIntroMusicTimer[i] = CreateTimer(0.5, Timer_PlayIntroMusicToPlayer, GetClientUserId(i));
				}
				else
				{
					g_PlayerIntroMusicTimer[i] = null;
				}
			}
			else
			{
				g_PlayerIntroMusicTimer[i] = null;
			}
		}
	}
	else
	{
		// Spawn the boss!
		if (!SF_SpecialRound(SPECIALROUND_MODBOSSES))
		{
			if (!SF_IsBoxingMap() && !SF_IsRenevantMap())
			{
				if (SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) || SF_SpecialRound(SPECIALROUND_DOOMBOX) || SF_SpecialRound(SPECIALROUND_2DOUBLE) || SF_SpecialRound(SPECIALROUND_2DOOM))
				{
					AddProfile(g_strRoundBossProfile);
					RemoveBossProfileFromQueueList(g_strRoundBossProfile);
				}
				else if (SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
				{
					AddProfile(g_strRoundBossProfile);
					AddProfile(g_strRoundBossProfile, _, _, _, false);
					AddProfile(g_strRoundBossProfile, _, _, _, false);
					RemoveBossProfileFromQueueList(g_strRoundBossProfile);
				}
				else if (!SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) && !SF_SpecialRound(SPECIALROUND_DOOMBOX) && !SF_SpecialRound(SPECIALROUND_2DOUBLE) && !SF_SpecialRound(SPECIALROUND_2DOOM) && !SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
				{
					SelectProfile(view_as<SF2NPC_BaseNPC>(0), g_strRoundBossProfile);
					RemoveBossProfileFromQueueList(g_strRoundBossProfile);
				}
			}
			else if (SF_IsBoxingMap())
			{
				char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
				ArrayList hSelectableBosses = GetSelectableBoxingBossProfileList().Clone();
				if (hSelectableBosses.Length > 0)
				{
					hSelectableBosses.GetString(GetRandomInt(0, hSelectableBosses.Length - 1), sBuffer, sizeof(sBuffer));
					AddProfile(sBuffer);
				}
				delete hSelectableBosses;
			}
		}
	}
	
	#if defined DEBUG
	if (g_DebugDetailConVar.IntValue > 0) DebugMessage("END InitializeNewGame()");
	#endif
}

public Action Timer_PlayIntroMusicToPlayer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	if (!IsClientInGame(client)) return Plugin_Stop;
	
	if (timer != g_PlayerIntroMusicTimer[client]) return Plugin_Stop;
	
	g_PlayerIntroMusicTimer[client] = null;
	
	EmitSoundToClient(client, g_strRoundIntroMusic, _, MUSIC_CHAN, SNDLEVEL_NONE);
	
	return Plugin_Stop;
}

static void StartIntroTextSequence()
{
	g_iRoundIntroText = 1;
	g_bRoundIntroTextDefault = false;
	g_hRoundIntroTextTimer = null;
	
	if (g_GamerulesEntity.IsValid())
	{
		SF2GameTextEntity textEntity = g_GamerulesEntity.IntroTextEntity;
		if (textEntity.IsValid())
		{
			g_hRoundIntroTextTimer = CreateTimer(g_GamerulesEntity.IntroTextDelay, Timer_NewIntroTextSequence, EntIndexToEntRef(textEntity.index), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	if (g_hRoundIntroTextTimer == null)
	{
		// Use old intro text sequence.
		g_hRoundIntroTextTimer = CreateTimer(0.0, Timer_IntroTextSequence, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

static Action Timer_NewIntroTextSequence(Handle timer, any data)
{
	if (!g_Enabled) return Plugin_Stop;
	if (g_hRoundIntroTextTimer != timer) return Plugin_Stop;
	
	SF2GameTextEntity textEntity = SF2GameTextEntity(EntRefToEntIndex(data));
	if (!textEntity.IsValid()) return Plugin_Stop;
	
	int iClients[MAXPLAYERS + 1];
	int iClientsNum;
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || g_PlayerEliminated[client]) continue;
		
		iClients[iClientsNum] = client;
		iClientsNum++;
	}
	
	char sMessage[512];
	textEntity.GetIntroMessage(sMessage, sizeof(sMessage));
	ShowHudTextUsingTextEntity(iClients, iClientsNum, textEntity.index, g_HudSync, sMessage);
	
	SF2GameTextEntity nextTextEntity = textEntity.NextIntroTextEntity;
	if (nextTextEntity.IsValid())
	{
		float flDuration = textEntity.GetPropFloat(Prop_Data, "m_textParms.fadeinTime")
		 + textEntity.GetPropFloat(Prop_Data, "m_textParms.fadeoutTime")
		 + textEntity.GetPropFloat(Prop_Data, "m_textParms.holdTime")
		 + textEntity.NextIntroTextDelay;
		
		g_hRoundIntroTextTimer = CreateTimer(flDuration, Timer_NewIntroTextSequence, EntIndexToEntRef(nextTextEntity.index), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	return Plugin_Continue;
}

public Action Timer_IntroTextSequence(Handle timer)
{
	if (!g_Enabled) return Plugin_Stop;
	if (g_hRoundIntroTextTimer != timer) return Plugin_Stop;
	
	float flDuration = 0.0;
	
	if (g_iRoundIntroText != 0)
	{
		bool bFoundGameText = false;
		
		int iClients[MAXPLAYERS + 1];
		int iClientsNum;
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || g_PlayerEliminated[i]) continue;
			
			iClients[iClientsNum] = i;
			iClientsNum++;
		}
		
		if (!g_bRoundIntroTextDefault)
		{
			char sTargetname[64];
			FormatEx(sTargetname, sizeof(sTargetname), "sf2_intro_text_%d", g_iRoundIntroText);
			
			int iGameText = FindEntityByTargetname(sTargetname, "game_text");
			if (iGameText && iGameText != INVALID_ENT_REFERENCE)
			{
				bFoundGameText = true;
				flDuration = GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeinTime") + GetEntPropFloat(iGameText, Prop_Data, "m_textParms.fadeoutTime") + GetEntPropFloat(iGameText, Prop_Data, "m_textParms.holdTime");
				
				char sMessage[512];
				GetEntPropString(iGameText, Prop_Data, "m_iszMessage", sMessage, sizeof(sMessage));
				ShowHudTextUsingTextEntity(iClients, iClientsNum, iGameText, g_HudSync, sMessage);
			}
		}
		else
		{
			if (g_iRoundIntroText == 2)
			{
				bFoundGameText = false;
				
				char sMessage[64];
				GetCurrentMap(sMessage, sizeof(sMessage));
				
				for (int i = 0; i < iClientsNum; i++)
				{
					ClientShowMainMessage(iClients[i], sMessage, 1);
				}
			}
		}
		
		if (g_iRoundIntroText == 1 && !bFoundGameText)
		{
			// Use default intro sequence. Eugh.
			g_bRoundIntroTextDefault = true;
			flDuration = g_IntroDefaultHoldTimeConVar.FloatValue / 2.0;
			
			for (int i = 0; i < iClientsNum; i++)
			{
				EmitSoundToClient(iClients[i], SF2_INTRO_DEFAULT_MUSIC, _, MUSIC_CHAN, SNDLEVEL_NONE);
			}
		}
		else
		{
			if (!bFoundGameText) return Plugin_Stop; // done with sequence; don't check anymore.
		}
	}
	
	g_iRoundIntroText++;
	g_hRoundIntroTextTimer = CreateTimer(flDuration, Timer_IntroTextSequence, _, TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action Timer_ActivateRoundFromIntro(Handle timer)
{
	if (!g_Enabled) return Plugin_Stop;
	if (g_hRoundIntroTimer != timer) return Plugin_Stop;
	
	// Obviously we don't want to spawn the boss when g_strRoundBossProfile isn't set yet.
	SetRoundState(SF2RoundState_Grace);
	SF2_RefreshRestrictions();
	
	// Spawn the boss!
	if (!SF_SpecialRound(SPECIALROUND_MODBOSSES))
	{
		if (!SF_IsBoxingMap() && !SF_IsRenevantMap())
		{
			if (SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) || SF_SpecialRound(SPECIALROUND_DOOMBOX) || SF_SpecialRound(SPECIALROUND_2DOUBLE) || SF_SpecialRound(SPECIALROUND_2DOOM))
			{
				AddProfile(g_strRoundBossProfile);
				RemoveBossProfileFromQueueList(g_strRoundBossProfile);
			}
			else if (SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
			{
				AddProfile(g_strRoundBossProfile);
				AddProfile(g_strRoundBossProfile, _, _, _, false);
				AddProfile(g_strRoundBossProfile, _, _, _, false);
				RemoveBossProfileFromQueueList(g_strRoundBossProfile);
			}
			else if (!SF_SpecialRound(SPECIALROUND_DOUBLETROUBLE) && !SF_SpecialRound(SPECIALROUND_DOOMBOX) && !SF_SpecialRound(SPECIALROUND_2DOUBLE) && !SF_SpecialRound(SPECIALROUND_2DOOM) && !SF_SpecialRound(SPECIALROUND_TRIPLEBOSSES))
			{
				SelectProfile(view_as<SF2NPC_BaseNPC>(0), g_strRoundBossProfile);
				RemoveBossProfileFromQueueList(g_strRoundBossProfile);
			}
		}
		else if (SF_IsBoxingMap())
		{
			char sBuffer[SF2_MAX_PROFILE_NAME_LENGTH];
			ArrayList hSelectableBosses = GetSelectableBoxingBossProfileList().Clone();
			if (hSelectableBosses.Length > 0)
			{
				hSelectableBosses.GetString(GetRandomInt(0, hSelectableBosses.Length - 1), sBuffer, sizeof(sBuffer));
				AddProfile(sBuffer);
			}
			delete hSelectableBosses;
		}
	}
	return Plugin_Stop;
}

void CheckRoundWinConditions()
{
	if (IsRoundInWarmup() || IsRoundEnding() || g_IgnoreRoundWinConditionsConVar.BoolValue) return;
	
	int iTotalCount = 0;
	int iAliveCount = 0;
	int iEscapedCount = 0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		iTotalCount++;
		if (!SF_SpecialRound(SPECIALROUND_1UP))
		{
			if (!g_PlayerEliminated[i] && !IsClientInDeathCam(i))
			{
				iAliveCount++;
				if (DidClientEscape(i)) iEscapedCount++;
			}
		}
		else
		{
			if (!g_PlayerEliminated[i] && !IsClientInDeathCam(i) && !g_bPlayerFullyDied1Up[i])
			{
				iAliveCount++;
				if (DidClientEscape(i)) iEscapedCount++;
			}
		}
	}
	
	if (iAliveCount == 0)
	{
		ForceTeamWin(TFTeam_Blue);
	}
	else
	{
		if (g_bRoundHasEscapeObjective)
		{
			if (iEscapedCount == iAliveCount)
			{
				ForceTeamWin(TFTeam_Red);
			}
		}
		else
		{
			if (g_PageMax > 0 && g_PageCount == g_PageMax)
			{
				ForceTeamWin(TFTeam_Red);
			}
		}
	}
}
