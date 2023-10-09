#include "ui/menudef.h"

#define Y_BTN(i) ( -140 + ( i * 20 ) )
#define ORIGIN_BTN(i) -200 Y_BTN(i)
#define RECT_BTN(i) ORIGIN_BTN(i) 400 20 2 2

#define Y_INPUT(i) ( -150 + ( i * 20 ) )
#define ORIGIN_INPUT(i) -110 Y_INPUT(i)
#define RECT_INPUT(i) ORIGIN_INPUT(i) 200 20 2 2

#define Y_SLIDER(i) ( -120 + ( i * 20 ) )
#define ORIGIN_SLIDER(i) -48 Y_SLIDER(i)
#define RECT_SLIDER(i) ORIGIN_SLIDER(i) 96 15 2 2

#define MENU_BUTTON(itemIndex,itemName,displayText,feedbackResponse) \
    itemDef \
    { \
        name buttonName \
        rect RECT_BTN(itemIndex) \
        foreColor 1 1 1 1 \
        backColor 0 0 0 0 \
        style 1 \
        origin 0 0 \
        background black \
        group mw2_button \
        type 1 \
        textAlign 9 \
        textScale 0.38 \
        textFont 8 \
        textStyle 5 \
        exp text ( displayText )\
        onFocus \
        { \
            play mouse_over; \
            setItemColor self backcolor 0.2 0.2 0.2 1; \
            setLocalVarBool ui_menuAButton 1; \
            setLocalVarFloat ui_popupYPos 0.000000; \
        } \
        leaveFocus \
        { \
            setItemColor self backcolor 0 0 0 0.0; \
            setLocalVarBool ui_menuAButton 1; \
        } \
        action \
        { \
            play mouse_click; \
            feedbackResponse \
        } \
        visible 1 \
    } \
		
#define MENU_TITLE(itemText,itemAlpha) \
	itemDef \
	{ \
		type ITEM_TYPE_TEXT \
		visible 1 \
		rect 0 -190 0 0 2 2\
		style WINDOW_STYLE_EMPTY \
		forecolor 1 1 1 itemAlpha \
		backcolor 0 0 0 0 \
		text itemText \
		textfont 9 \
		textscale 0.5 \
		textAlign 9 \
		DECORATION \
	} \

#define MENU_LOGO(itemAlpha) \
	itemDef \
    { \
        rect -21 -210 42 42 2 2 \
        style 1 \
        border 0 \
        ownerdraw 0 \
        ownerdrawFlag 0 \
        borderSize 0 \
        foreColor 1 1 1 itemAlpha \
        backColor 1 1 1 itemAlpha \
        borderColor 0 0 0 0 \
        outlineColor 0 0 0 0 \
        decoration \
        type 0 \
        visible 1 \
        exp material ( ankh_icon ) \
    } \

#define MENU_SLIDER_CENTERED(itemIndex,textName,sliderName,displayText,dvarName,dvarRange,feedbackResponse) \
    itemDef \
    { \
        name textName \
        rect RECT_BTN(itemIndex) \
        type 1 \
        textscale .25 \
        style 0 \
        textStyle 3 \
        textAlign 9 \
        textScale 0.38 \
        textFont 8 \
        textStyle 5 \
        forecolor 1 1 1 1 \
        backcolor 0.1 0.1 0.1 0.3 \
        visible 1 \
        decoration \
        exp text ( displayText ) \
    } \
    itemDef \
    { \
        name sliderName \
        rect RECT_SLIDER(itemIndex) \
        style 0 \
        border 0 \
        borderSize 0 \
        foreColor 1 1 1 1 \
        type 10 \
        dvarfloat dvarRange \
        visible 1 \
        onFocus \
        { \
            play mouse_over; \
        } \
        leaveFocus \
        { \
            feedbackResponse \
        } \
        action \
        { \
            setDvar dvarName \
        } \
    } \


#define MENU_INPUT(itemIndex,textName,inputName,displayText,tempDvar,execOnFocus,execLeaveFocus,feedbackResponse) \
    itemDef \
    { \
        name textName \
        rect RECT_BTN(itemIndex) \
        type 1 \
        textscale .25 \
        style 0 \
        textStyle 3 \
        textAlign 9 \
        textScale 0.38 \
        textFont 8 \
        textStyle 5 \
        forecolor 1 1 1 1 \
        visible 1 \
        decoration \
        exp text ( displayText ) \
    } \
    itemDef \
    { \
        name inputName \
        rect RECT_INPUT(itemIndex) \
        style 1 \
        border 0 \
        ownerdraw 0 \
        ownerdrawFlag 0 \
        borderSize 0 \
        foreColor 1 1 1 1 \
        backColor 0 0 0 0.3 \
        borderColor 0 0 0 0 \
        outlineColor 0 0 0 0 \
        origin 10 32 \
        type 4 \
        align 0 \
        textAlign 8 \
        textAlignX 0 \
        textAlignY 0 \
        textScale 0.375 \
        textStyle 0 \
        textFont 3 \
        feeder 0 \
        text " " \
        visible 1 \
        dvar tempDvar \
        onFocus \
        { \
            execOnFocus \
            setfocus inputName; \
        } \
        leaveFocus \
        { \
            execLeaveFocus \
            feedbackResponse \
        } \
    } \

// Please change this it's awful
#define SETUP_ACTION_STARTDEV \
	if (dvarstring(ui_mapname) == "mp_afghan") \
	{ \
		exec "devmap mp_afghan"; \
	} \
	if (dvarstring(ui_mapname) == "mp_boneyard") \
	{ \
		exec "devmap mp_boneyard"; \
	} \
	if (dvarstring(ui_mapname) == "mp_brecourt") \
	{ \
		exec "devmap mp_brecourt"; \
	} \
	if (dvarstring(ui_mapname) == "mp_checkpoint") \
	{ \
		exec "devmap mp_checkpoint"; \
	} \
	if (dvarstring(ui_mapname) == "mp_derail") \
	{ \
		exec "devmap mp_derail"; \
	} \
	if (dvarstring(ui_mapname) == "mp_estate") \
	{ \
		exec "devmap mp_estate"; \
	} \
	if (dvarstring(ui_mapname) == "mp_favela") \
	{ \
		exec "devmap mp_favela"; \
	} \
	if (dvarstring(ui_mapname) == "mp_highrise") \
	{ \
		exec "devmap mp_highrise"; \
	} \
	if (dvarstring(ui_mapname) == "mp_invasion") \
	{ \
		exec "devmap mp_invasion"; \
	} \
	if (dvarstring(ui_mapname) == "mp_nightshift") \
	{ \
		exec "devmap mp_nightshift"; \
	} \
	if (dvarstring(ui_mapname) == "mp_quarry") \
	{ \
		exec "devmap mp_quarry"; \
	} \
	if (dvarstring(ui_mapname) == "mp_rundown") \
	{ \
		exec "devmap mp_rundown"; \
	} \
	if (dvarstring(ui_mapname) == "mp_rust") \
	{ \
		exec "devmap mp_rust"; \
	} \
	if (dvarstring(ui_mapname) == "mp_subbase") \
	{ \
		exec "devmap mp_subbase"; \
	} \
	if (dvarstring(ui_mapname) == "mp_terminal") \
	{ \
		exec "devmap mp_terminal"; \
	} \
	if (dvarstring(ui_mapname) == "mp_underpass") \
	{ \
		exec "devmap mp_underpass"; \
	} \
	if (dvarstring(ui_mapname) == "af_caves") \
	{ \
		exec "devmap af_caves"; \
	} \
	if (dvarstring(ui_mapname) == "af_chase") \
	{ \
		exec "devmap af_chase"; \
	} \
	if (dvarstring(ui_mapname) == "airport") \
	{ \
		exec "devmap airport"; \
	} \
	if (dvarstring(ui_mapname) == "arcadia") \
	{ \
		exec "devmap arcadia"; \
	} \
	if (dvarstring(ui_mapname) == "boneyard") \
	{ \
		exec "devmap boneyard"; \
	} \
	if (dvarstring(ui_mapname) == "cliffhanger") \
	{ \
		exec "devmap cliffhanger"; \
	} \
	if (dvarstring(ui_mapname) == "co_hunted") \
	{ \
		exec "devmap co_hunted"; \
	} \
	if (dvarstring(ui_mapname) == "contingency") \
	{ \
		exec "devmap contingency"; \
	} \
	if (dvarstring(ui_mapname) == "dc_whitehouse") \
	{ \
		exec "devmap dc_whitehouse"; \
	} \
	if (dvarstring(ui_mapname) == "dcburning") \
	{ \
		exec "devmap dcburning"; \
	} \
	if (dvarstring(ui_mapname) == "dcemp") \
	{ \
		exec "devmap dcemp"; \
	} \
	if (dvarstring(ui_mapname) == "ending") \
	{ \
		exec "devmap ending"; \
	} \
	if (dvarstring(ui_mapname) == "estate") \
	{ \
		exec "devmap estate"; \
	} \
	if (dvarstring(ui_mapname) == "favela") \
	{ \
		exec "devmap favela"; \
	} \
    if (dvarstring(ui_mapname) == "roadkill") \
	{ \
		exec "devmap roadkill"; \
	} \
	if (dvarstring(ui_mapname) == "favela_escape") \
	{ \
		exec "devmap favela_escape"; \
	} \
	if (dvarstring(ui_mapname) == "gulag") \
	{ \
		exec "devmap gulag"; \
	} \
	if (dvarstring(ui_mapname) == "invasion") \
	{ \
		exec "devmap invasion"; \
	} \
	if (dvarstring(ui_mapname) == "iw4_credits") \
	{ \
		exec "devmap iw4_credits"; \
	} \
	if (dvarstring(ui_mapname) == "oilrig") \
	{ \
		exec "devmap oilrig"; \
	} \
	if (dvarstring(ui_mapname) == "so_bridge") \
	{ \
		exec "devmap so_bridge"; \
	} \
	if (dvarstring(ui_mapname) == "so_ghillies") \
	{ \
		exec "devmap so_ghillies"; \
	} \
	if (dvarstring(ui_mapname) == "trainer") \
	{ \
		exec "devmap trainer"; \
	} \
	if (dvarstring(ui_mapname) == "mp_abandon") \
	{ \
		exec "devmap mp_abandon"; \
	} \
	if (dvarstring(ui_mapname) == "mp_bloc") \
	{ \
		exec "devmap mp_bloc"; \
	} \
	if (dvarstring(ui_mapname) == "mp_bog_sh") \
	{ \
		exec "devmap mp_bog_sh"; \
	} \
	if (dvarstring(ui_mapname) == "mp_cargoship") \
	{ \
		exec "devmap mp_cargoship"; \
	} \
	if (dvarstring(ui_mapname) == "mp_cargoship_sh") \
	{ \
		exec "devmap mp_cargoship_sh"; \
	} \
	if (dvarstring(ui_mapname) == "mp_compact") \
	{ \
		exec "devmap mp_compact"; \
	} \
	if (dvarstring(ui_mapname) == "mp_complex") \
	{ \
		exec "devmap mp_complex"; \
	} \
	if (dvarstring(ui_mapname) == "mp_crash") \
	{ \
		exec "devmap mp_crash"; \
	} \
	if (dvarstring(ui_mapname) == "mp_cross_fire") \
	{ \
		exec "devmap mp_cross_fire"; \
	} \
	if (dvarstring(ui_mapname) == "mp_fuel2") \
	{ \
		exec "devmap mp_fuel2"; \
	} \
	if (dvarstring(ui_mapname) == "mp_killhouse") \
	{ \
		exec "devmap mp_killhouse"; \
	} \
	if (dvarstring(ui_mapname) == "mp_nuked") \
	{ \
		exec "devmap mp_nuked"; \
	} \
	if (dvarstring(ui_mapname) == "mp_overgrown") \
	{ \
		exec "devmap mp_overgrown"; \
	} \
	if (dvarstring(ui_mapname) == "mp_storm") \
	{ \
		exec "devmap mp_storm"; \
	} \
	if (dvarstring(ui_mapname) == "mp_strike") \
	{ \
		exec "devmap mp_strike"; \
	} \
	if (dvarstring(ui_mapname) == "mp_trailerpark") \
	{ \
		exec "devmap mp_trailerpark"; \
	} \
	if (dvarstring(ui_mapname) == "mp_vacant") \
	{ \
		exec "devmap mp_vacant"; \
	} \
	if (dvarstring(ui_mapname) == "mp_estate_tropical") \
	{ \
		exec "devmap mp_estate_tropical"; \
	} \
	if (dvarstring(ui_mapname) == "mp_fav_tropical") \
	{ \
		exec "devmap mp_fav_tropical"; \
	} \
	if (dvarstring(ui_mapname) == "mp_crash_trop") \
	{ \
		exec "devmap mp_crash_trop"; \
	} \
	if (dvarstring(ui_mapname) == "mp_storm_spring") \
	{ \
		exec "devmap mp_storm_spring"; \
	} \
	if (dvarstring(ui_mapname) == "mp_shipment") \
	{ \
		exec "devmap mp_shipment"; \
	} \
	if (dvarstring(ui_mapname) == "mp_shipment_long") \
	{ \
		exec "devmap mp_shipment_long"; \
	} \
	if (dvarstring(ui_mapname) == "mp_rust_long") \
	{ \
		exec "devmap mp_rust_long"; \
	} \
	if (dvarstring(ui_mapname) == "mp_firingrange") \
	{ \
		exec "devmap mp_firingrange"; \
	} \
	if (dvarstring(ui_mapname) == "mp_frost") \
	{ \
		exec "devmap mp_frost"; \
	} \
    if (dvarstring(ui_mapname) == "mp_test") \
	{ \
		exec "devmap mp_test"; \
	} \
	if (dvarstring(ui_mapname) == "mp_bloc_sh") \
	{ \
		exec "devmap mp_bloc_sh"; \
	}

itemDef
{
    rect 0 0 700 500 4 4
    style 3
    foreColor 0.13 0.13 0.13 1
    decoration 
    visible 1
    exp material ("preview_" + dvarString (ui_mapname))
    exp rect x ( -10 + ( sin ( milliseconds( ) / 3000 ) * 10) )
}
itemDef
{
    rect 0 0 640 480 4 4
    style 3
    foreColor 1 1 1 0.08
    background white
    decoration 
    visible 1
}
itemDef
{
    rect 0 0 640 480 4 4
    style 3
    forecolor 1 0.4 0.1 0.523696
    background mockup_bg_glow
    decoration
    visible 1
    exp forecolor a ( ( ( sin ( milliseconds( ) / 1500 ) + 1 ) * 0.250000 ) + 0.250000  )
}