 /* Victor Macho
    Clase HUD en unreal
Posicion del raton y debug de variables
 */

class MyHud extends UTHUD;

var bool    bDrawTraces;    //Dibuja o no los rayos en el debug
var DoorOfLiesHud MyHudHealth;

var MU_Minimap GameMinimap;
var Float TileSize;
var Int MapDim;
var Int BoxSize;
var Color PlayerColors[2];


simulated event PostBeginPlay() //Al empezar
{
    super.PostBeginPlay();
    `Log("The custom hud is alive !");

    MyHudHealth = new class'DoorOfLiesHud';
    MyHudHealth.Start();
    MyHudHealth.UpdateLife(DoorOfLiesPlayerController(PlayerOwner).Pawn.Health);

    GameMinimap = DoorOfLiesGame(WorldInfo.Game).GameMinimap;
}

//Activa o desactiva ver los rayos en debug
exec function ToggleIsometricDebug()
{
    bDrawTraces = !bDrawTraces;
    if(bDrawTraces) `Log("Showing debug line trace for mouse");
    else `Log("Disabling debug line trace for mouse");
}

//Define la posicion del raton con Scaleform
function vector2D GetMouseCoordinates()
{
    return MyHudHealth.GetMouseCoordinates();
}

//Despues del render define la posicion de la camara
event PostRender()
{
    local DoorOfLiesPlayerCamera PlayerCam;
    local DoorOfLiesPlayerController IsoPlayerController;
    local int TeamIndex;
    local LocalPlayer Lp;

    if(bShowHUD)
    {
        RenderDelta = WorldInfo.TimeSeconds - LastHUDRenderTime;
        LastHUDRenderTime = WorldInfo.TimeSeconds;

        bIsSplitscreen = class'Engine'.static.IsSplitScreen();

        ResolutionScaleX = Canvas.ClipX/1024;
        ResolutionScale = Canvas.ClipY/768;
        if ( bIsSplitScreen )
            ResolutionScale *= 2.0;

        if ( (ViewX != Canvas.ClipX) || (ViewY != Canvas.ClipY) )
        {
            ResolutionChanged();
            ViewX = Canvas.ClipX;
            ViewY = Canvas.ClipY;
        }
        UTGRI = UTGameReplicationInfo(WorldInfo.GRI);

        if ( ScoreboardMovie != None && ScoreboardMovie.bMovieIsOpen )
        {
            ScoreboardMovie.Tick(RenderDelta);
        }

        if (LeaderboardMovie != none && LeaderboardMovie.bMovieIsOpen)
            LeaderboardMovie.Tick(RenderDelta);

        LP = LocalPlayer(PlayerOwner.Player);
        bIsFirstPlayer = (LP != none) && (LP.Outer.GamePlayers[0] == LP);

        // Clear the flag
        bHudMessageRendered = false;


        PawnOwner = Pawn(PlayerOwner.ViewTarget);
        if ( PawnOwner == None )
        {
            PawnOwner = PlayerOwner.Pawn;
        }

        UTPawnOwner = UTPawn(PawnOwner);
        if ( UTPawnOwner == none )
        {
            if ( UDKVehicleBase(PawnOwner) != none )
            {
                UTPawnOwner = UTPawn( UDKVehicleBase(PawnOwner).Driver);
            }
        }


        // draw any debug text in real-time
        PlayerOwner.DrawDebugTextList(Canvas,RenderDelta);

        // Cache the current Team Index of this hud and the GRI
        TeamIndex = 2;
        if ( PawnOwner != None )
        {
            if ( (PawnOwner.PlayerReplicationInfo != None) && (PawnOwner.PlayerReplicationInfo.Team != None) )
            {
                TeamIndex = PawnOwner.PlayerReplicationInfo.Team.TeamIndex;
            }
        }
        else if ( (PlayerOwner.PlayerReplicationInfo != None) && (PlayerOwner.PlayerReplicationInfo.team != None) )
        {
            TeamIndex = PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
        }

        HUDScaleX = Canvas.ClipX/1280;
        HUDScaleY = Canvas.ClipX/1280;

        GetTeamColor(TeamIndex, TeamHUDColor, TeamTextColor);

        FullWidth = Canvas.ClipX;
        FullHeight = Canvas.ClipY;

        // Always update the Damage Indicator
        UpdateDamage();

        // let iphone draw any always present overlays

        if (bShowMobileHud)
        {
            DrawInputZoneOverlays();
        }

        RenderMobileMenu();



        IsoPlayerController = DoorOfLiesPlayerController(PlayerOwner); // Cast de la clase playerController para obtener el jugador
        IsoPlayerController.PlayerMouse = GetMouseCoordinates(); // Obtenemos las coordenadas del raton 2D
        IsoPlayerController.PlayerMouse = AjustResolutionCoordinate(IsoPlayerController.PlayerMouse);

        //Proyectamos las coordenadas 2D en el plano 3D en la variable MousePosWorldNormal
        Canvas.DeProject(IsoPlayerController.PlayerMouse, IsoPlayerController.MousePosWorldLocation, IsoPlayerController.MousePosWorldNormal);

        PlayerCam = DoorOfLiesPlayerCamera(IsoPlayerController.PlayerCamera); //Obtenemos la camara con cast

        //Calculate a trace from Player camera + 100 up(z) in direction of deprojected MousePosWorldNormal (the direction of the mouse).
        //-----------------
        IsoPlayerController.RayDir = IsoPlayerController.MousePosWorldNormal; //Colocamos la direccion del rayo segun la posicion del raton
        //Start the trace at the player camera (isometric) + 100 unit z and a little offset in front of the camera (direction *10)
        IsoPlayerController.StartTrace = (PlayerCam.ViewTarget.POV.Location + vect(0,0,100)) + IsoPlayerController.RayDir * 10;
        //End this ray at start + the direction multiplied by given distance (5000 unit is far enough generally)
        IsoPlayerController.EndTrace = IsoPlayerController.StartTrace + IsoPlayerController.RayDir * 5000;

        //Trace MouseHitWorldLocation each frame to world location (here you can get from the trace the actors that are hit by the trace, for the sake of this
        //simple tutorial, we do noting with the result, but if you would filter clicks only on terrain, or if the player clicks on an npc, you would want to inspect
        //the object hit in the StartFire function
        IsoPlayerController.TraceActor = Trace(IsoPlayerController.MouseHitWorldLocation, IsoPlayerController.MouseHitWorldNormal, IsoPlayerController.EndTrace, IsoPlayerController.StartTrace, true);
        
        //Calculate the pawn eye location for debug ray and for checking obstacles on click.
        IsoPlayerController.PawnEyeLocation = Pawn(PlayerOwner.ViewTarget).Location + Pawn(PlayerOwner.ViewTarget).EyeHeight * vect(0,0,1);

        DrawHUD(); //Rutina de dibujado normal

        if(bDrawTraces) //Si bDrawTraces == true se dibujan los rayos de la camara
        {
            //If display is enabled from console, then draw Pathfinding routes and rays.
            super.DrawRoute(Pawn(PlayerOwner.ViewTarget));
            DrawTraceDebugRays();
        }
    }
}

//Ajustamos la resolucion del HUD con la de la pantalla
function vector2d AjustResolutionCoordinate(vector2d mouseCoordinates)
{
    local float coefx;
    local float coefy;

    coefx = float(ViewX) / 1920;
    coefy = float(ViewY) / 1080;

    mouseCoordinates.X *= coefx;
    mouseCoordinates.Y *= coefy;

    return mouseCoordinates;
}

//Se dibujan los rayos de la camara
function DrawTraceDebugRays()
{
    local DoorOfLiesPlayerController IsoPlayerController;
    IsoPlayerController = DoorOfLiesPlayerController(PlayerOwner);
    
    //Draw Trace from the camera to the world using
    Draw3DLine(IsoPlayerController.StartTrace, IsoPlayerController.EndTrace, MakeColor(255,128,128,255));

    //Draw eye ray for collision and determine if a clear running is permitted(no obstacles between pawn && destination)
    Draw3DLine(IsoPlayerController.PawnEyeLocation, IsoPlayerController.MouseHitWorldLocation, MakeColor(0,200,255,255));
}

//Dibuja variables despues del postrender
function DrawHUD()
{
    //local Vector Direction;
    local string StringMessage;

    local Camera Camera;
    local Pawn   Pawn;  
    
    if(bDrawTraces) //Si bDrawTraces == true se dibujan
    {
        //Display traced actor class under mouse cursor for fun :)
        if(DoorOfLiesPlayerController(PlayerOwner).TraceActor != none)
        {
            StringMessage = "Actor selected:"@DoorOfLiesPlayerController(PlayerOwner).TraceActor.class;
        }
        

        // Background
        /*Canvas.SetPos( 0, 0 );
        Canvas.SetDrawColor( 0, 0, 0, 128 );
        Canvas.DrawRect( 500, 500 );

        Canvas.Font = class'Engine'.Static.GetSmallFont();
        Canvas.SetDrawColor(0,255,0,255);*/

        // Camera
        Camera = PlayerOwner.PlayerCamera;
        Canvas.SetPos( 10, 410 );
        Canvas.DrawText( "CameraPos: " $ Camera.Location );
        Canvas.SetPos( 10, 425 );
        Canvas.DrawText( "CameraRot: " $ Camera.Rotation );

        // Pawn
        Pawn = PLayerOwner.Pawn;
        Canvas.SetPos( 10, 440 );
        Canvas.DrawText( "PawnPos: " $ Pawn.Location );
        Canvas.SetPos( 10, 455 );
        Canvas.DrawText( "PawnRot: " $ Pawn.Rotation );

        // Actor
        Canvas.SetPos( 10, 470 );
        Canvas.DrawText( "Velocity: " $ Pawn.Velocity );
        Canvas.SetPos( 10, 485 );
        Canvas.DrawText( "Acceleration: " $ Pawn.Acceleration );


        Canvas.SetPos( 10, 500 );
        Canvas.DrawText( "Mouse X: " $ GetMouseCoordinates().X);
        Canvas.SetPos( 10, 515 );
        Canvas.DrawText( "Mouse Y: " $ GetMouseCoordinates().Y );


        Canvas.DrawColor = MakeColor(255,183,11,255); //Cambiamos el color con el que se dibuja el mensaje
        Canvas.SetPos( 10, 530 );
        Canvas.DrawText( StringMessage, false, , , TextRenderInfo );


        Canvas.SetPos( 10, 545 );
        Canvas.DrawText( "Fire Manas:" $ DoorOfLiesPlayerController(PlayerOwner).fire_hability.manas);
        Canvas.SetPos( 10, 560 );
        Canvas.DrawText( "Water Manas: " $ DoorOfLiesPlayerController(PlayerOwner).water_hability.manas);
        Canvas.SetPos( 10, 575 );
        Canvas.DrawText( "Stone Manas:" $ DoorOfLiesPlayerController(PlayerOwner).stone_hability.manas);
        Canvas.SetPos( 10, 590 );
        Canvas.DrawText( "Wind Manas:" $ DoorOfLiesPlayerController(PlayerOwner).wind_hability.manas);
    }

    if(!MyHudHealth.IsGamePaused) DrawMap(); //COMPROBAR DIVISION POR CERO
}

function PreCalcValues()
{
    super.PreCalcValues();

    if(MyHudHealth != none)
    {
        MyHudHealth.SetViewport(0,0,SizeX, SizeY);
        MyHudHealth.SetViewScaleMode(SM_NoScale);
        MyHudHealth.SetAlignment(Align_TopLeft);
    }
}

function float GetPlayerHeading()
{
    local Float PlayerHeading;
    local Rotator PlayerRotation;
    local Vector v;

    PlayerRotation.Yaw = PlayerOwner.Pawn.Rotation.Yaw;
    v = vector(PlayerRotation);
    PlayerHeading = GetHeadingAngle(v);
    PlayerHeading = UnwindHeading(PlayerHeading);

    while (PlayerHeading < 0)
        PlayerHeading += PI * 2.0f;
    
    return PlayerHeading;
}

function DrawMap()
{
    local Float TrueNorth,PlayerHeading;
    local Float MapRotation,CompassRotation;
    local Vector PlayerPos, ClampedPlayerPos, RotPlayerPos, DisplayPlayerPos, StartPos;
    local LinearColor MapOffset;
    local Float ActualMapRange;
    local HumanoidPawn C;

    local MaterialInstanceConstant MatInst;
    local MaterialInstanceConstant MatInstCompassOverlay;

    if(GameMinimap != none)
    {
        //Set MapDim & BoxSize accounting for the current resolution        
        MapPosition.X = default.MapPosition.X * FullWidth + ViewX - MapDim;
        MapPosition.Y = default.MapPosition.Y * FullHeight;
        MapDim = default.MapDim * ResolutionScale;
        BoxSize = default.BoxSize * ResolutionScale;

        //Calculate map range values
        ActualMapRange = FMax(  GameMinimap.MapRangeMax.X - GameMinimap.MapRangeMin.X,
                            GameMinimap.MapRangeMax.Y - GameMinimap.MapRangeMin.Y);

        //Calculate normalized player position
        PlayerPos.X = (PlayerOwner.Pawn.Location.Y - GameMinimap.MapCenter.Y) / ActualMapRange;
        PlayerPos.Y = (GameMinimap.MapCenter.X - PlayerOwner.Pawn.Location.X) / ActualMapRange;

        //Calculate clamped player position
        ClampedPlayerPos.X = FClamp(PlayerPos.X,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));
        ClampedPlayerPos.Y = FClamp(PlayerPos.Y,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));

        //Get north direction and player's heading
        TrueNorth = GameMinimap.GetRadianHeading();
        Playerheading = GetPlayerHeading();

        //Calculate rotation values
        if(GameMinimap.bForwardAlwaysUp)
        {
            MapRotation = PlayerHeading;
            CompassRotation = PlayerHeading - TrueNorth;
        }
        else
        {
            MapRotation = PlayerHeading - TrueNorth;
            CompassRotation = MapRotation;
        }

        //Calculate position for displaying the player in the map
        DisplayPlayerPos.X = VSize(PlayerPos) * Cos( ATan2(PlayerPos.Y, PlayerPos.X) - MapRotation);
        DisplayPlayerPos.Y = VSize(PlayerPos) * Sin( ATan2(PlayerPos.Y, PlayerPos.X) - MapRotation);

        //Calculate player location after rotation
        RotPlayerPos.X = VSize(ClampedPlayerPos) * Cos( ATan2(ClampedPlayerPos.Y, ClampedPlayerPos.X) - MapRotation);
        RotPlayerPos.Y = VSize(ClampedPlayerPos) * Sin( ATan2(ClampedPlayerPos.Y, ClampedPlayerPos.X) - MapRotation);

        //Calculate upper left UV coordinate
        StartPos.X = FClamp(RotPlayerPos.X + (0.5 - (TileSize / 2.0)),0.0,1.0 - TileSize);
        StartPos.Y = FClamp(RotPlayerPos.Y + (0.5 - (TileSize / 2.0)),0.0,1.0 - TileSize);
        //StartPos.X = FClamp(DisplayPlayerPos.X + (0.5 - (TileSize / 2.0)),TileSize/-2,1.0 - TileSize/2);
        //StartPos.Y = FClamp(DisplayPlayerPos.Y + (0.5 - (TileSize / 2.0)),TileSize/-2,1.0 - TileSize/2);

        //Calculate texture panning for alpha
        MapOffset.R =  FClamp(-1.0 * RotPlayerPos.X,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));
        MapOffset.G =  FClamp(-1.0 * RotPlayerPos.Y,-0.5 + (TileSize / 2.0),0.5 - (TileSize / 2.0));
        //MapOffset.R =  FClamp(-1.0 * DisplayPlayerPos.X,-0.5,0.5);
        //MapOffset.G =  FClamp(-1.0 * DisplayPlayerPos.Y,-0.5,0.5);


        //Cambiamos los valores al mapa, para ello creamos en tiempo real copias del material para que no de error
        MatInst = new(self) Class'MaterialInstanceConstant';
        MatInstCompassOverlay= new(self) Class'MaterialInstanceConstant';

        MatInst.SetParent(GameMinimap.Minimap.GetMaterial());
        MatInstCompassOverlay.SetParent(GameMinimap.CompassOverlay.GetMaterial());

        MatInst.SetVectorParameterValue('MapOffset',MapOffset);
        MatInst.SetScalarParameterValue('MapRotation',MapRotation);
        MatInst.SetScalarParameterValue('TileSize',TileSize);
        MatInst.SetTextureParameterValue('BorderTex',Texture2D'CompassContent.map_border');
        MatInst.SetTextureParameterValue('MinimapTex',Texture2D'Mapa1.Texture.mapa1Tex');

        
        MatInstCompassOverlay.SetTextureParameterValue('OverlayAlpha',Texture2D'CompassContent.map_border');
        MatInstCompassOverlay.SetTextureParameterValue('OverlayTex',Texture2D'CompassContent.map_compass_border');
        MatInstCompassOverlay.SetScalarParameterValue('CompassRotation',CompassRotation);
        

        GameMinimap.Minimap = MatInst;
        GameMinimap.CompassOverlay = MatInstCompassOverlay;

        //Draw the map
        Canvas.SetPos(MapPosition.X,MapPosition.Y);
        Canvas.DrawMaterialTile(GameMinimap.Minimap,MapDim,MapDim,StartPos.X,StartPos.Y,TileSize,TileSize);

        //Draw the player's location
        Canvas.SetPos(  MapPosition.X + MapDim * (((DisplayPlayerPos.X + 0.5) - StartPos.X) / TileSize) - (BoxSize / 2),
                    MapPosition.Y + MapDim * (((DisplayPlayerPos.Y + 0.5) - StartPos.Y) / TileSize) - (BoxSize / 2));
        Canvas.SetDrawColor(PlayerColors[0].R,
                        PlayerColors[0].G,
                        PlayerColors[0].B,
                        PlayerColors[0].A);
        Canvas.DrawBox(BoxSize,BoxSize);

        /*****************************
        *  Draw Humanoids
        *****************************/

        foreach WorldInfo.AllPawns(class'HumanoidPawn',C)
        {
            if(C != PlayerOwner.Pawn)
            {
                //Calculate normalized player position
                PlayerPos.Y = (GameMinimap.MapCenter.X - C.Location.X) / ActualMapRange;
                PlayerPos.X = (C.Location.Y - GameMinimap.MapCenter.Y) / ActualMapRange;

                //Calculate position for displaying the player in the map
                DisplayPlayerPos.X = VSize(PlayerPos) * Cos( ATan2(PlayerPos.Y, PlayerPos.X) - MapRotation);
                DisplayPlayerPos.Y = VSize(PlayerPos) * Sin( ATan2(PlayerPos.Y, PlayerPos.X) - MapRotation);

                if(VSize(DisplayPlayerPos - RotPlayerPos) <= ((TileSize / 2.0) - (TileSize * Sqrt(2 * Square(BoxSize / 2)) / MapDim)))
                {
                    //Draw the player's location
                    Canvas.SetPos(  MapPosition.X + MapDim * (((DisplayPlayerPos.X + 0.5) - StartPos.X) / TileSize) - (BoxSize / 2),
                                MapPosition.Y + MapDim * (((DisplayPlayerPos.Y + 0.5) - StartPos.Y) / TileSize) - (BoxSize / 2));
                    Canvas.SetDrawColor(PlayerColors[1].R,
                                    PlayerColors[1].G,
                                    PlayerColors[1].B,
                                    PlayerColors[1].A);
                    Canvas.DrawBox(BoxSize,BoxSize);
                }
            }
        }

        //Draw the compass overlay
        Canvas.SetPos(MapPosition.X,MapPosition.Y);
        Canvas.DrawMaterialTile(GameMinimap.CompassOverlay,MapDim,MapDim,0.0,0.0,1.0,1.0);
    }
    else GameMinimap = DoorOfLiesGame(WorldInfo.Game).GameMinimap;
}

exec function MapSizeUp()
{
    MapDim *= 2;
    BoxSize *= 2;
}

exec function MapSizeDown()
{
    MapDim /= 2;
    BoxSize /= 2;
}

exec function MapZoomIn()
{
    TileSize = 1.0 / FClamp(Int((1.0 / TileSize) + 1.0) + 0.5,1.5,10.5);
}

exec function MapZoomOut()
{
    TileSize = 1.0 / FClamp(Int((1.0 / TileSize) - 1.0) + 0.5,1.5,10.5);
}

DefaultProperties
{
    bDrawTraces = true;
    bShowScores = false;

    MapDim=128
    BoxSize=12
    PlayerColors(0)=(R=255,G=255,B=255,A=255)
    PlayerColors(1)=(R=96,G=255,B=96,A=255)
    TileSize=0.4
    MapPosition=(X=0.000000,Y=0.000000)
}