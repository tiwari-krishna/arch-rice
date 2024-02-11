#define SESSION_FILE "/tmp/dwm-session"

/* appearance */
enum showtab_modes { showtab_never, showtab_auto, showtab_nmodes, showtab_always};
static const int showtab			= showtab_auto;        /* Default tab bar show mode */
static const int toptab				= True;               /* False means bottom tab bar */

static const double activeopacity   = 1.0f;     /* Window opacity when it's focused (0 <= opacity <= 1) */
static const double inactiveopacity = 1.0f;   /* Window opacity when it's inactive (0 <= opacity <= 1) */
static       Bool bUseOpacity       = True;     /* Starts with opacity on any unfocused windows */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0;   	/* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 5;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;     /* 0 means no systray */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */
static const int user_bh            = 20;        /* 0 means that dwm will calculate bar height, >= 1 means dwm will user_bh as bar height */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int fborderpx = 3;        /* border pixel of floating windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 4;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 4;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 10;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "Fira Code medium:antialias=true:autohint=true:weight=SemiBold:pixelsize=16", "FontAwesome:size=16" };
static const char bg_Bar[]          = "#000000";
static const char fg_Bar[]          = "#eeeeee";
static const char act_Tag[]         = "#1a576b";
static const char title_fg[]        = "#5cddf7";
static const char float_bor[]       = "#ffffff";
static const char *colors[][4]      = {
	/*               fg         bg         border       float*/
	[SchemeNorm] = { fg_Bar, bg_Bar, bg_Bar,   float_bor },
	[SchemeSel]  = { fg_Bar, act_Tag,  act_Tag,     float_bor  },
	[SchemeStatus]={ act_Tag, bg_Bar,  NULL,        NULL  },
};

static const char *const autostart[] = {
	"dunst", NULL,
	NULL /* terminate */
};

typedef struct {
	const char *name;
	const void *cmd;
} Sp;
const char *spcmd1[] = {"alacritty", "--class", "spterm", NULL };
const char *spcmd2[] = {"alacritty", "--class", "spfm", "-e", "ranger", NULL };
const char *spcmd3[] = {"alacritty", "--class", "spmpc", "-e", "ncmpcpp", NULL };
const char *spcmd4[] = {"galculator", NULL };
static Sp scratchpads[] = {
	/* name          cmd  */
	{"spterm",      spcmd1},
	{"spfm",    spcmd2},
	{"spmpc",    spcmd3},
	{"galculator",   spcmd4},
};

/* status bar */
static const Block blocks[] = {
	/* fg     command				interval	signal */
	{ "#3BFF30", "stat-timedate",		60,		1},
	{ "#f0da16", "stat-volume",			0,	    2},
	{ "#3098FF", "stat-battery",		5,		3},
	{ "#FF9B30", "stat-backlight",		0,		4},
	{ "#FF3080", "stat-wifi",			5,		8},
	//{ "#FF9B30", "stat-weather",		0,		7},
	{ "#FFF130",  "stat-music",			5,		5},
};

/* inverse the order of the blocks, comment to disable */
#define INVERSED	1
/* delimeter between blocks commands. NULL character ('\0') means no delimeter. */
static char delimiter[] = " ";
/* max number of character that one block command can output */
#define CMDLENGTH	50


/* tagging */
static const char *tags[] = { "α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class     instance  title           tags mask  isfloating  isterminal  noswallow  monitor  notallowed  isfreesize */
	{ "Gimp",    NULL,     NULL,           0,         1,          0,           0,        -1,        0,          1 },
	{ "Firefox", NULL,     NULL,           0,         0,          0,           0,        -1,        0,          0 },
	{ "st",      NULL,     NULL,           0,         0,          1,           0,        -1,        0,          0 },
	{ "Alacritty",  NULL,   NULL,          0,         0,          1,           0,        -1,        0,          0 },
	{ NULL,      NULL,     "Event Tester", 0,         0,          0,           1,        -1,        0,          0 }, /* xev */
	{ NULL,	     "spterm",  NULL,	       SPTAG(0),  1,	      1,           0,	     -1,        0,          0 },
	{ NULL,	     "spfm",	NULL,	       SPTAG(1),  1,	      1,           0,	     -1,        0,          0 },
	{ NULL,	     "spmpc",	NULL,	       SPTAG(2),  1,	      1,           0,	     -1,        0,          0 },
	{ NULL,	     "galculator",  NULL,      SPTAG(3),  1,	      1,           0,	     -1,        0,          0 },
};

/* layout(s) */
static const float mfact     = 0.53; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int nmaxmaster  = 5;        /* maximum number of clients allowed in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 0; /* 1 will force focus on the fullscreen window */
static const int mainmon = 0; /* xsetroot will only change the bar on this monitor */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "functions.c"

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "M&S",      tile },    /* first entry is default */
    { "M&S=",      bstack },

	{ "Tab",      monocle },
	{ "==",      NULL },    /* no layout function means floating behavior */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{1, {{MODKEY, KEY}},                            view,           {.ui = 1 << TAG} }, \
	{1, {{MODKEY|ControlMask, KEY}},                toggleview,     {.ui = 1 << TAG} }, \
	{1, {{MODKEY|ShiftMask, KEY}},                  tag,            {.ui = 1 << TAG} }, \
	{1, {{MODKEY|ControlMask|ShiftMask, KEY}},      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
#define TERMINAL "$TERMINAL"
#define BROWSER "$BROWSER"

#include <X11/XF86keysym.h>

/* commands */
static const char *dmenucmd[] = { "dmenu_run", NULL };
static const char *termcmd[]  = { "alacritty", NULL };

static const Keychord keychords[] = {
	/* modifier                     key        function        argument */
	{1, {{MODKEY, XK_space}},                   spawn,          {.v = dmenucmd } },
	{1, {{MODKEY, XK_Return}},                  spawn,          {.v = termcmd } },
	{1, {{MODKEY, XK_s}},                       togglesticky,   {0} },
    {1, {{MODKEY|ShiftMask, XK_s}},             toggleopacity,  {0} },

	{1, {{MODKEY, XK_b}},                       togglebar,      {0} },
	{1, {{MODKEY, XK_j}},                       focusstack,     {.i = +1 } },
	{1, {{MODKEY, XK_k}},                       focusstack,     {.i = -1 } },
	{1, {{MODKEY|ShiftMask, XK_j}},             movestack,      {.i = +1 } },
	{1, {{MODKEY|ShiftMask, XK_k}},             movestack,      {.i = -1 } },

	{1, {{MODKEY|ControlMask, XK_k}},           incnmaster,     {.i = +1 } },
	{1, {{MODKEY|ControlMask, XK_j}},           incnmaster,     {.i = -1 } },
    {1, {{MODKEY|ControlMask, XK_l}},           resetnmaster,   {0} },
	{1, {{MODKEY, XK_h}},                       setmfact,       {.f = -0.05} },
	{1, {{MODKEY, XK_l}},                       setmfact,       {.f = +0.05} },
	{1, {{MODKEY|ShiftMask, XK_h}},             setcfact,       {.f = +0.25} },
	{1, {{MODKEY|ShiftMask, XK_l}},             setcfact,       {.f = -0.25} },
	{1, {{MODKEY|ControlMask, XK_h}},           setcfact,       {.f =  0.00} },
	{1, {{MODKEY|ControlMask, XK_Return}},      zoom,           {0} },
	{1, {{MODKEY, XK_g}},                       reorganizetags, {0} },

    {1, {{MODKEY|ShiftMask, XK_r}},             unfloatvisible, {0} },
    {1, {{MODKEY, XK_r}},                       movecenter,     {0} },
	{1, {{MODKEY|ShiftMask, XK_f}},             togglefullscr,  {0} },
	{1, {{MODKEY|ShiftMask, XK_space}},         togglealwaysontop, {0} },
	{1, {{MODKEY|ControlMask, XK_Tab}},         view,           {0} },

    {1, {{MODKEY, XK_t}},                       setlayout,      {.v = &layouts[0]} },//tile
    {1, {{MODKEY|ShiftMask, XK_t}},             setlayout,      {.v = &layouts[1]} },//bottom tile
    {1, {{MODKEY|ControlMask, XK_t}},           setlayout,      {.v = &layouts[2]} },//monocle
    {1, {{MODKEY|ShiftMask, XK_y}},             setlayout,      {.v = &layouts[3]} },//floating
	{1, {{MODKEY, XK_y}},                       tabmode,        {-1} },
	{1, {{MODKEY, XK_f}},                       togglefloating, {0} },
    {1, {{MODKEY|ShiftMask, XK_Tab}},           layoutscroll,   {.i = -1 } },
	{1, {{MODKEY, XK_Tab}},                     layoutscroll,   {.i = +1 } },
//	{1, {{MODKEY, XK_space}},                   setlayout,      {0} },

    {1, {{ControlMask|ShiftMask, XK_Return}},   focusurgent,    {0} },
	{1, {{MODKEY, XK_0}},                       view,           {.ui = ~0 } },
	{1, {{MODKEY|ShiftMask, XK_0}},             tag,            {.ui = ~0 } },
	{1, {{MODKEY, XK_comma}},                   focusmon,       {.i = -1 } },
	{1, {{MODKEY, XK_period}},                  focusmon,       {.i = +1 } },
	{1, {{MODKEY|ShiftMask, XK_comma}},         tagmon,         {.i = -1 } },
	{1, {{MODKEY|ShiftMask, XK_period}},        tagmon,         {.i = +1 } },

	{1, {{MODKEY|ShiftMask, XK_Return}}, 	    togglescratch,  {.ui = 0 } },
	{1, {{Mod1Mask|ShiftMask, XK_Return}},	    togglescratch,  {.ui = 1 } },
	{1, {{MODKEY|Mod1Mask, XK_Return}},	        togglescratch,  {.ui = 2 } },
	{1, {{MODKEY, XK_c}},	                    togglescratch,  {.ui = 3 } },

	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)

	{1, {{MODKEY, XK_q}},                       killclient,     {0} },
	{1, {{MODKEY|ShiftMask, XK_q}},             quit,           {0} },
	{1, {{MODKEY|ControlMask, XK_q}},           quit,           {1} }, 

	{1, {{MODKEY,  XK_Next}},                   scratchpad_show, {0} },
	{1, {{MODKEY,  XK_Prior}},                  scratchpad_hide, {0} },
	{1, {{MODKEY,  XK_End}},                    scratchpad_remove,{0} },

    {1, {{MODKEY, XK_p}},                       incrgaps,       {.i = +1 } },
    {1, {{MODKEY, XK_o}},                       incrgaps,       {.i = -1 } },
    {1, {{MODKEY|ShiftMask, XK_p}},             togglegaps,     {0} },
    {1, {{MODKEY|ShiftMask, XK_o}},             defaultgaps,    {0} },
	{1, {{MODKEY|ControlMask, XK_p}},           incrigaps,      {.i = +1 } },
	{1, {{MODKEY|ControlMask|ShiftMask, XK_p}}, incrigaps,      {.i = -1 } },
	{1, {{MODKEY|ControlMask, XK_o}},           incrogaps,      {.i = +1 } },
	{1, {{MODKEY|ControlMask|ShiftMask, XK_o}}, incrogaps,      {.i = -1 } },

	{1, {{MODKEY|ShiftMask, XK_i}},             aspectresize,   {.i = -24} },
	{1, {{MODKEY, XK_i}},                       aspectresize,   {.i = +24} },
	{1, {{MODKEY, XK_Down}},                    moveresize,     {.v = "0x 25y 0w 0h" } },
	{1, {{MODKEY, XK_Up}},                      moveresize,     {.v = "0x -25y 0w 0h" } },
	{1, {{MODKEY, XK_Right}},                   moveresize,     {.v = "25x 0y 0w 0h" } },
	{1, {{MODKEY, XK_Left}},                    moveresize,     {.v = "-25x 0y 0w 0h" } },
	{1, {{MODKEY|ShiftMask, XK_Down}},          moveresize,     {.v = "0x 0y 0w 25h" } },
	{1, {{MODKEY|ShiftMask, XK_Up}},            moveresize,     {.v = "0x 0y 0w -25h" } },
	{1, {{MODKEY|ShiftMask, XK_Right}},         moveresize,     {.v = "0x 0y 25w 0h" } },
	{1, {{MODKEY|ShiftMask, XK_Left}},          moveresize,     {.v = "0x 0y -25w 0h" } },
	{1, {{MODKEY|ControlMask, XK_Up}},          moveresizeedge, {.v = "t"} },
	{1, {{MODKEY|ControlMask, XK_Down}},        moveresizeedge, {.v = "b"} },
	{1, {{MODKEY|ControlMask, XK_Left}},        moveresizeedge, {.v = "l"} },
	{1, {{MODKEY|ControlMask, XK_Right}},       moveresizeedge, {.v = "r"} },
	{1, {{MODKEY|ControlMask|ShiftMask, XK_Up}},    moveresizeedge, {.v = "T"} },
	{1, {{MODKEY|ControlMask|ShiftMask, XK_Down}},  moveresizeedge, {.v = "B"} },
	{1, {{MODKEY|ControlMask|ShiftMask, XK_Left}},  moveresizeedge, {.v = "L"} },
	{1, {{MODKEY|ControlMask|ShiftMask, XK_Right}}, moveresizeedge, {.v = "R"} },

    {1, {{MODKEY|ShiftMask, XK_bracketleft}},   shiftboth,      { .i = -1 }	},
    {1, {{MODKEY|ShiftMask, XK_bracketright}},  shiftboth,      { .i = +1 }	},
    {1, {{MODKEY, XK_bracketleft}},             shiftview,      { .i = -1 }	},
    {1, {{MODKEY, XK_bracketright}},            shiftview,      { .i = +1 }	},
    {1, {{MODKEY|ControlMask, XK_bracketleft}}, shifttag,      { .i = -1 }	},
    {1, {{MODKEY|ControlMask, XK_bracketright}}, shifttag,      { .i = +1 }	},

    {1, {{MODKEY|ControlMask, XK_v}},                 	spawn,      SHCMD("pavucontrol") },
    {1, {{Mod1Mask|ShiftMask, XK_s}},                spawn,      SHCMD("maim -s ~/Data/screenshots/$(date +%Y-%m-%d-%s).png") },
    {1, {{Mod1Mask, XK_s}},                          spawn,      SHCMD("maim ~/Data/screenshots/$(date +%Y-%m-%d-%s).png") },
    {1, {{ControlMask|ShiftMask, XK_s}},             spawn,      SHCMD("maim -s | xclip -selection clipboard -t image/png") },

    {1, {{ShiftMask, XK_Print}},                        spawn,      SHCMD("maim -s ~/Data/screenshots/$(date +%Y-%m-%d-%s).png") },
    {1, {{0, XK_Print}},                                spawn,      SHCMD("maim ~/Data/screenshots/$(date +%Y-%m-%d-%s).png") },

    {1, {{0, XF86XK_AudioMute}},                        spawn,      SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK toggle; kill -36 $(pidof dwm)") },
    {1, {{0, XF86XK_AudioRaiseVolume}},                 spawn,      SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+; kill -36 $(pidof dwm)") },
    {1, {{0, XF86XK_AudioLowerVolume}},                 spawn,      SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-; kill -36 $(pidof dwm)") },
    //{1, {{0, XF86XK_AudioMute}},                 				spawn,      SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ toggle; kill -36 $(pidof dwm)") },
    {1, {{0, XF86XK_AudioMicMute}},                 		spawn,      SHCMD("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ toggle; kill -36 $(pidof dwm)") },
    {1, {{0, XF86XK_MonBrightnessUp}},                  spawn,      SHCMD("brightnessctl -e set 2%+; kill -38 $(pidof dwm)") },
    {1, {{0, XF86XK_MonBrightnessDown}},                spawn,      SHCMD("brightnessctl -e set 2%-; kill -38 $(pidof dwm)") },
    {1, {{0, XF86XK_AudioPrev}},                        spawn,      SHCMD("mpc prev; kill -39 $(pidof dwm)") },
    {1, {{0, XF86XK_AudioNext}},                        spawn,      SHCMD("mpc next; kill -39 $(pidof dwm)") },
    {1, {{0, XF86XK_AudioPlay}},                        spawn,      SHCMD("mpc toggle; kill -39 $(pidof dwm)") },
    {1, {{0, XF86XK_HomePage}},                         spawn,      SHCMD(BROWSER) },
//    {1, {{0, XF86XK_PickupPhone}},                      spawn,      SHCMD(BROWSER) },
//    {1, {{0, XF86XK_HangupPhone}},                      spawn,      SHCMD(BROWSER) },
//    {1, {{0, XF86XK_Help}},                         		spawn,      SHCMD(BROWSER) },
    {1, {{0, XF86XK_Favorites}},                        spawn,      SHCMD("rofi -show drun -show-icons") },
    {1, {{0, XF86XK_Calculator}},            						togglescratch,  {.ui = 3 } },
    {1, {{Mod1Mask|MODKEY, XK_equal}},                  spawn,      SHCMD("brightnessctl -e set 2%+; kill -38 $(pidof dwm)") },
    {1, {{Mod1Mask|MODKEY, XK_minus}},                  spawn,      SHCMD("brightnessctl -e set 2%-; kill -38 $(pidof dwm)") },

    {1, {{Mod1Mask, XK_Up}},                            spawn,      SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+; kill -36 $(pidof dwm)") },
    {1, {{Mod1Mask, XK_Down}},                          spawn,      SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-; kill -36 $(pidof dwm)") },
    {1, {{Mod1Mask|ShiftMask, XK_space}},               spawn,      SHCMD("mpc toggle; kill -39 $(pidof dwm)") },
    {1, {{Mod1Mask|ShiftMask, XK_Right}},               spawn,      SHCMD("mpc next; kill -39 $(pidof dwm)") },
    {1, {{Mod1Mask|ShiftMask, XK_Left}},                spawn,      SHCMD("mpc prev; kill -39 $(pidof dwm)") },
    {1, {{Mod1Mask, XK_bracketleft}},                   spawn,      SHCMD("mpc seek -10") },
    {1, {{Mod1Mask|ShiftMask, XK_bracketleft}},         spawn,      SHCMD("mpc seek -60") },
    {1, {{Mod1Mask, XK_bracketright}},                  spawn,      SHCMD("mpc seek +10") },
    {1, {{Mod1Mask|ShiftMask, XK_bracketright}},        spawn,      SHCMD("mpc seek +60") },
    {1, {{Mod1Mask, XK_Left}},                          spawn,      SHCMD("mpc vol -5") },
    {1, {{Mod1Mask, XK_Right}},                         spawn,      SHCMD("mpc vol +5") },
    {1, {{Mod1Mask|ControlMask, XK_space}},             spawn,      SHCMD("mpc single") },
    {1, {{Mod1Mask, XK_apostrophe}},	                spawn,		SHCMD("mpc seek 0%") },
    {1, {{Mod1Mask, XK_F1}},	                        spawn,		SHCMD("playerctl play-pause") },
    {1, {{Mod1Mask, XK_F2}},	                        spawn,		SHCMD("playerctl next") },
    {1, {{Mod1Mask, XK_F3}},	                        spawn,		SHCMD("playerctl previous") },
    {1, {{Mod1Mask, XK_F4}},	                        spawn,		SHCMD("playerctl stop") },
    {1, {{Mod1Mask, XK_equal}},	                        spawn,		SHCMD("playerctl volume 5+") },
    {1, {{Mod1Mask, XK_minus}},	                        spawn,		SHCMD("playerctl volume 5-") },
    {1, {{Mod1Mask|ShiftMask, XK_minus}},	            spawn,		SHCMD("playerctl postition 10-") },
    {1, {{Mod1Mask|ShiftMask, XK_equal}},	            spawn,		SHCMD("playerctl position 10+") },

    {1, {{Mod1Mask,	XK_r}},	                            spawn,		SHCMD("xradio-listen") },
    {1, {{Mod1Mask,	XK_m}},	                            spawn,		SHCMD("xmovie-watch") },
    {1, {{Mod1Mask,	XK_b}},	                            spawn,		SHCMD("xread-book") },
    {1, {{MODKEY, XK_BackSpace}},             					spawn,      SHCMD("xpower") },
    {1, {{MODKEY|ShiftMask, XK_c}},                     spawn,      SHCMD("confedit") },
    {1, {{Mod1Mask, XK_BackSpace}},                     spawn,      SHCMD("gromit-mpx") },
    {1, {{Mod1Mask|ShiftMask, XK_BackSpace}},           spawn,      SHCMD("killall gromit-mpx") },
    {1, {{MODKEY|ControlMask, XK_w}},                   spawn,      SHCMD("xweb-search") },

    //{1, MODKEY, XK_n}},                               spawn,      SHCMD(TERMINAL " -e newsboat") },
    {1, {{Mod1Mask|ShiftMask, XK_w}},                   spawn,      SHCMD("sxiv -q -o -t -r ~/Data/Media/wallpapers") },
    {1, {{MODKEY|ShiftMask, XK_g}},                     spawn,      SHCMD("gimp") },
    {1, {{MODKEY, XK_grave}},                           spawn,      SHCMD("st") },
    {1, {{MODKEY|ShiftMask, XK_grave}},                 spawn,      SHCMD("libreoffice") },
    {1, {{MODKEY|ShiftMask, XK_d}},                     spawn,      SHCMD("pcmanfm") },
    {1, {{MODKEY|ShiftMask, XK_e}},                     spawn,      SHCMD(TERMINAL " -e htop") },
   // {1, {{MODKEY|ShiftMask, XK_n}},                   spawn,      SHCMD(TERMINAL " -e newsboat") },
    {1, {{MODKEY, XK_w}},                               spawn,      SHCMD(BROWSER) },
    {1, {{MODKEY|ShiftMask, XK_v}},                     spawn,      SHCMD("minitube") },
    {1, {{MODKEY, XK_F9}},                     					spawn,      SHCMD("screenkey") },
    {1, {{MODKEY|ShiftMask, XK_F9}},                    spawn,      SHCMD("killall screenkey") },
    {1, {{MODKEY, XK_F12}},                     				spawn,      SHCMD("xrecording-menu") },
    {1, {{MODKEY|ShiftMask, XK_F12}},                   spawn,      SHCMD("killall ffmpeg") },

    {1, {{MODKEY, XK_u}},                               spawn,      SHCMD("redshift -P -O 6300") },
    {1, {{MODKEY|ShiftMask, XK_u}},                     spawn,      SHCMD("redshift -P -O 5000") },

    //{1, {{MODKEY, XK_n}},                               spawn,      SHCMD(TERMINAL " -e neomutt") },
    {1, {{MODKEY, XK_v}},                               spawn,      SHCMD(TERMINAL " -e transg-tui") },
    {1, {{MODKEY, XK_x}},                               spawn,      SHCMD(TERMINAL " -e ytfzf") },
    {1, {{MODKEY|ShiftMask, XK_n}},                     spawn,      SHCMD(TERMINAL " -e nvim $HOME/.cache/ScratchNote.md") },
    {1, {{MODKEY|ShiftMask, XK_x}},                     spawn,      SHCMD("slock") },
		{1, {{MODKEY, XK_slash}},                           spawn,      SHCMD("xmount-drives") },
    {1, {{MODKEY|ControlMask, XK_slash}},               spawn,      SHCMD("mount-and") },
    {1, {{MODKEY|ShiftMask, XK_slash}},                 spawn,      SHCMD("xumount-drives") },
    {1, {{MODKEY, XK_e}},                     					spawn,      SHCMD("xqr-gen") },
    {1, {{MODKEY|ControlMask, XK_r}},                   spawn,      SHCMD("webcam-show") },

    {1, {{Mod1Mask, XK_w}},                             spawn,      SHCMD(TERMINAL " -e nmtui") },
    {1, {{MODKEY|ShiftMask, XK_b}},                     spawn,      SHCMD("xbrowser-launch") },
    {1, {{MODKEY|ShiftMask, XK_m}},                     spawn,      SHCMD("xmpv-play") },
    {1, {{MODKEY, XK_d}},                               spawn,      SHCMD(TERMINAL " -e vid-grab") },
    {1, {{MODKEY, XK_z}},                               spawn,      SHCMD("clipmenu") },
    {1, {{MODKEY|ShiftMask, XK_Menu}},                  spawn,      SHCMD("rofi -show drun -show-icons") },
    {1, {{MODKEY, XK_a}},                               spawn,      SHCMD(TERMINAL " -e lf") },
    {1, {{MODKEY, XK_Menu}},                            spawn,      SHCMD("rofi -show emoji") },
    {1, {{MODKEY, XK_semicolon}},                       spawn,      SHCMD("xspellchk") },
    {1, {{MODKEY|ShiftMask, XK_w}},                     spawn,      SHCMD("xopen-bookmarks") },
    {1, {{MODKEY, XK_apostrophe}},                      spawn,      SHCMD("notify-timedate") },
    {1, {{MODKEY|ShiftMask, XK_apostrophe}},            spawn,      SHCMD("notify-battery") },
    {1, {{MODKEY|ControlMask, XK_apostrophe}},          spawn,      SHCMD("notify-wifi") },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },

	{ ClkStatusText,        0,              Button1,        sendstatusbar,   {.i = 1 } },
	{ ClkStatusText,        0,              Button2,        sendstatusbar,   {.i = 2 } },
	{ ClkStatusText,        0,              Button3,        sendstatusbar,   {.i = 3 } },
	{ ClkStatusText,        0,              Button4,        sendstatusbar,   {.i = 4 } },
	{ ClkStatusText,        0,              Button5,        sendstatusbar,   {.i = 5 } },
	{ ClkStatusText,        ShiftMask,      Button1,        sendstatusbar,   {.i = 6 } },

	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
	{ ClkTabBar,            0,              Button1,        focuswin,       {0} },
};
