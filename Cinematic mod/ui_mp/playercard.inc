#define PLAYERCARD(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_BG1(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_TITLE(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_NAME(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_ICON(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_BG2(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_IDK(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_RANK(SLOT, CONTROLLER, RT1, RT2, X, Y)
	
#define PLAYERCARD2(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_BG1(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_TITLE(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_NAME2(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_ICON(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_IDK(SLOT, CONTROLLER, RT1, RT2, X, Y) \
	PLAYERCARD_RANK(SLOT, CONTROLLER, RT1, RT2, X, Y)
	
#define PLAYERCARD_BG1(SLOT, CONTROLLER, RT1, RT2, X, Y) \
		itemDef \
		{ \
			rect 0 0 274 72 RT1 RT2 \
			style 3 \
			decoration \
			visible 1 \
			forecolor 0 0 0 0.25 \
			background "white" \
			textscale 0.55 \
			exp rect x ( ( X ) ) \
			exp rect y ( ( Y ) ) \
			visible when ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) ) \
		} \
		itemDef \
		{ \
			rect 0 0 274 72 RT1 RT2 \
			style 1 \
			decoration \
			visible 1 \
			forecolor 1 1 1 1 \
			backcolor 1 1 1 1 \
			background "cardtitle_248x48" \
			textfont 6 \
			textalign 4 \
			textaligny -20 \
			textscale 0.375 \
			textstyle 7 \
			exp rect x ( ( X ) ) \
			exp rect y ( ( Y ) ) \
			visible when ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) ) \
		}

#define PLAYERCARD_AVATAR(SLOT, CONTROLLER, RT1, RT2, X, Y) \
		itemDef \
		{ \
			rect 0 0 64 64 RT1 RT2 \
			style 1 \
			decoration \
			visible 1 \
			forecolor 1 1 1 1 \
			exp rect x ( ( X ) + 4 ) \
			exp rect y ( ( Y ) + 4 ) \
			backcolor 1 1 1 1 \
			exp material ( "playercard_" + SLOT ) \
		}
		
#define PLAYERCARD_TITLE(SLOT, CONTROLLER, RT1, RT2, X, Y) \
		itemDef \
		{ \
			rect 0 0 160 32 RT1 RT2 \
			style 1 \
			decoration \
			visible 1 \
			forecolor 1 1 1 1 \
			backcolor 1 1 1 1 \
			textfont 3 \
			textalign 9 \
			textscale 0.375 \
			textstyle 8 \
			exp rect x ( ( X ) + 66 ) \
			exp rect y ( ( Y ) - 2 ) \
			exp forecolor r ( tablelookupbyrow( "mp/cardTitleTable.csv" , getplayercardinfo( 1 , CONTROLLER , SLOT ) , 3 ) ) \
			exp forecolor g ( tablelookupbyrow( "mp/cardTitleTable.csv" , getplayercardinfo( 1 , CONTROLLER , SLOT ) , 4 ) ) \
			exp forecolor b ( tablelookupbyrow( "mp/cardTitleTable.csv" , getplayercardinfo( 1 , CONTROLLER , SLOT ) , 5 ) ) \
			visible when ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) ) \
			exp text ( "@" + tablelookupbyrow( "mp/cardTitleTable.csv" , getplayercardinfo( 1 , CONTROLLER , SLOT ) , 1 ) ) \
			exp material ( tablelookupbyrow( "mp/cardTitleTable.csv" , getplayercardinfo( 1 , CONTROLLER , SLOT ) , 2 ) ) \
		}
		
#define PLAYERCARD_NAME(SLOT, CONTROLLER, RT1, RT2, X, Y) \
		itemDef \
		{ \
			rect 0 0 160 18 RT1 RT2 \
			decoration \
			visible 1 \
			forecolor 0.6 0.8 0.6 1 \
			textfont 10 \
			textalign 4 \
			textalignx 8 \
			textscale 0.3333 \
			textstyle 8 \
			exp rect x ( ( X ) + 66 ) \
			exp rect y ( ( Y ) + 28 ) \
			visible when ( ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) && ( getplayercardinfo( 6 , CONTROLLER , SLOT ) && getplayercardinfo( 6 , CONTROLLER , SLOT ) == ( ( ( team( "name" ) == "TEAM_AXIS" ) * 1 ) + ( ( team( "name" ) == "TEAM_ALLIES" ) * 2 ) ) ) ) ) \
			exp text ( getplayercardinfo( 8 , CONTROLLER , SLOT ) ) \
		} \
		itemDef \
		{ \
			rect 0 0 160 18 RT1 RT2 \
			decoration \
			visible 1 \
			forecolor 0.8 0.35 0.4 1 \
			textfont 10 \
			textalign 4 \
			textalignx 8 \
			textscale 0.3333 \
			textstyle 8 \
			exp rect x ( ( X ) + 66 ) \
			exp rect y ( ( Y ) + 28 ) \
			visible when ( ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) && ( !getplayercardinfo( 6 , CONTROLLER , SLOT ) || getplayercardinfo( 6 , CONTROLLER , SLOT ) != ( ( ( team( "name" ) == "TEAM_AXIS" ) * 1 ) + ( ( team( "name" ) == "TEAM_ALLIES" ) * 2 ) ) ) ) ) \
			exp text ( getplayercardinfo( 8 , CONTROLLER , SLOT ) ) \
		}
		
#define PLAYERCARD_NAME2(SLOT, CONTROLLER, RT1, RT2, X, Y) \
		itemDef \
		{ \
			rect 0 0 160 18 RT1 RT2 \
			decoration \
			visible 1 \
			forecolor 1 1 1 1 \
			textfont 10 \
			textalign 4 \
			textalignx 8 \
			textscale 0.3333 \
			textstyle 8 \
			exp rect x ( ( X ) + 66 ) \
			exp rect y ( ( Y ) + 28 ) \
			visible when ( 1 && ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) ) \
			exp text ( getplayercardinfo( 8 , CONTROLLER , SLOT ) ) \
		}
		
#define PLAYERCARD_ICON(SLOT, CONTROLLER, RT1, RT2, X, Y) \
		itemDef \
		{ \
			rect 0 0 48 48 RT1 RT2 \
			style 3 \
			decoration \
			visible 1 \
			forecolor 1 1 1 1 \
			textscale 0.55 \
			exp rect x ( ( ( X ) + 66 ) + 160 ) \
			exp rect y ( ( Y ) ) \
			visible when ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) ) \
			exp material ( tablelookupbyrow( "mp/cardIconTable.csv" , getplayercardinfo( 2 , CONTROLLER , SLOT ) , 1 ) ) \
		}
		
#define PLAYERCARD_BG2(SLOT, CONTROLLER, RT1, RT2, X, Y) \
		itemDef \
		{ \
			rect 0 0 47 25 RT1 RT2 \
			style 3 \
			decoration \
			visible 1 \
			forecolor 0 0 0 0.25 \
			background "white" \
			textscale 0.55 \
			exp rect x ( ( ( X ) + 66 ) + 160 ) \
			exp rect y ( ( Y ) + 46 ) \
			visible when ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) ) \
		} \
		itemDef \
		{ \
			rect 0 0 47 25 RT1 RT2 \
			style 1 \
			decoration \
			visible 1 \
			forecolor 1 1 1 1 \
			backcolor 1 1 1 1 \
			background "cardtitle_248x20" \
			textscale 0.55 \
			exp rect x ( ( ( X ) + 66 ) + 160 ) \
			exp rect y ( ( Y ) + 46 ) \
			visible when ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) ) \
		}
		
#define PLAYERCARD_IDK(SLOT, CONTROLLER, RT1, RT2, X, Y) \
		itemDef \
		{ \
			rect 0 0 208 20 RT1 RT2 \
			style 1 \
			decoration \
			visible 1 \
			forecolor 1 1 1 1 \
			textfont 3 \
			textalign 8 \
			textalignx 8 \
			textscale 0.375 \
			textstyle 7 \
			exp rect x ( ( ( X ) + 66 ) + 164 ) \
			exp rect y ( ( Y ) + 48 ) \
			visible when ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) && getplayercardinfo( 9 , CONTROLLER , SLOT ) != "" ) \
			exp text ( "[" + getplayercardinfo( 9 , CONTROLLER , SLOT ) + "]" ) \
		}
		
#define PLAYERCARD_RANK(SLOT, CONTROLLER, RT1, RT2, X, Y) \
		itemDef \
		{ \
			rect 0 0 20 20 RT1 RT2 \
			style 1 \
			decoration \
			visible 1 \
			forecolor 1 1 1 1 \
			backcolor 1 1 1 1 \
			textscale 0.55 \
			exp rect x ( ( ( X ) + 66 ) + 164 ) \
			exp rect y ( ( Y ) + 48 ) \
			visible when ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) && ( getplayercardinfo( 4 , CONTROLLER , SLOT ) >= 0 ) ) \
			exp material ( tablelookup( "mp/rankIconTable.csv" , 0 , getplayercardinfo( 4 , CONTROLLER , SLOT ) , ( getplayercardinfo( 5 , CONTROLLER , SLOT ) + 1 ) ) ) \
		} \
		itemDef \
		{ \
			rect 0 0 20 20 RT1 RT2 \
			decoration \
			visible 1 \
			forecolor 1 1 1 1 \
			textfont 3 \
			textalign 9 \
			textalignx 20 \
			textscale 0.375 \
			textstyle 7 \
			exp rect x ( ( ( X ) + 66 ) + 164 ) \
			exp rect y ( ( Y ) + 48 ) \
			visible when ( ( getplayercardinfo( 0 , CONTROLLER , SLOT ) != 0 ) && ( getplayercardinfo( 4 , CONTROLLER , SLOT ) >= 0 ) ) \
			exp text ( tablelookup( "mp/rankTable.csv" , 0 , getplayercardinfo( 4 , CONTROLLER , SLOT ) , 14 ) ) \
		}