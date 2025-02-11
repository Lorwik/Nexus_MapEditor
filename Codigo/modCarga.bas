Attribute VB_Name = "modCarga"
Option Explicit

Public Type tSetupMods

    ' VIDEO
    byMemory    As Integer
    OverrideVertexProcess As Byte
    LimiteFPS As Boolean
    FPSShow As Boolean
    
    'MOSTRAR
    Preview As Byte
    
End Type

Public ClientSetup As tSetupMods

Public Type tCabecera
    Desc As String * 255
    CRC As Long
    MagicWord As Long
End Type

Public MiCabecera As tCabecera

Private Lector As clsIniManager
Public Const CLIENT_FILE As String = "Config.ini"

'********************************
'Load Map with .CSM format
'********************************
Private Type tMapHeader
    NumeroBloqueados As Long
    NumeroLayers(2 To 4) As Long
    NumeroTriggers As Long
    NumeroLuces As Long
    NumeroParticulas As Long
    NumeroNPCs As Long
    NumeroOBJs As Long
    NumeroTE As Long
End Type

Private Type tDatosBloqueados
    X As Integer
    y As Integer
End Type

Private Type tDatosGrh
    X As Integer
    y As Integer
    GrhIndex As Long
End Type

Private Type tDatosTrigger
    X As Integer
    y As Integer
    Trigger As Integer
End Type

Private Type tDatosLuces
    R As Integer
    G As Integer
    B As Integer
    range As Byte
    X As Integer
    y As Integer
End Type

Private Type tDatosParticulas
    X As Integer
    y As Integer
    Particula As Long
End Type

Private Type tDatosNPC
    X As Integer
    y As Integer
    NPCIndex As Integer
End Type

Private Type tDatosObjs
    X As Integer
    y As Integer
    objindex As Integer
    ObjAmmount As Integer
End Type

Private Type tDatosTE
    X As Integer
    y As Integer
    DestM As Integer
    DestX As Integer
    DestY As Integer
End Type

Private Type tMapSize
    XMax As Integer
    XMin As Integer
    YMax As Integer
    YMin As Integer
End Type

Private Type tMapDat
    map_name As String
    battle_mode As Boolean
    backup_mode As Boolean
    restrict_mode As String
    music_number As String
    zone As String
    terrain As String
    ambient As String
    lvlMinimo As String
    LuzBase As Long
    version As Long
    NoTirarItems As Boolean
End Type

Public MapSize As tMapSize
Private MapDat As tMapDat
'********************************
'END - Load Map with .CSM format
'********************************

'Lista de cabezas
Public Type tIndiceCabeza
    Head(1 To 4) As Long
End Type

Public Type tIndiceCuerpo
    Body(1 To 4) As Long
    HeadOffsetX As Integer
    HeadOffsetY As Integer
End Type

Public Type tIndiceFx
    Animacion As Long
    OffsetX As Integer
    OffsetY As Integer
End Type

Public Type tIndiceArmas
    weapon(1 To 4) As Long
End Type

Public Type tIndiceEscudos
    shield(1 To 4) As Long
End Type

Public NumHeads As Integer
Public NumCascos As Integer
Public NumEscudosAnims As Integer
Public grhCount As Long

Public Type NpcData

    name As String
    Body As Integer
    Head As Integer
    Heading As Byte

End Type

Public NumNPCs   As Long
Public NpcData() As NpcData

Public Type ObjData

    name As String 'Nombre del obj
    ObjType As Integer 'Tipo enum que determina cuales son las caract del obj
    GrhIndex As Long ' Indice del grafico que representa el obj
    GrhSecundario As Integer
    Info As String
    Ropaje As Integer 'Indice del grafico del ropaje
    WeaponAnim As Integer ' Apunta a una anim de armas
    ShieldAnim As Integer ' Apunta a una anim de escudo
    Texto As String
    Cerrada As Byte
    Subtipo As Byte

End Type

Public NumOBJs     As Long
Public ObjData()   As ObjData

Type SupData
    name As String
    Grh As Long
    Width As Byte
    Height As Byte
    Block As Boolean
    Capa As Byte
End Type

Public MaxSup As Long
Public SupData() As SupData

Public Sub IniciarCabecera()

    With MiCabecera
        .Desc = "NexusAO mod Argentum Online by Noland Studios."
        .CRC = Rnd * 245
        .MagicWord = Rnd * 92
    End With
    
End Sub

Public Sub CargarConfiguracion()
    On Local Error GoTo fileErr:
    
    Dim tStr As String
    
    Call IniciarCabecera

    DirInit = App.Path & "\Init\"

    Set Lector = New clsIniManager
    Call Lector.Initialize(DirInit & "Config.ini")
    
    DirRecursos = Lector.GetValue("RUTAS", "Recursos")
    DirDats = Lector.GetValue("RUTAS", "Dats")
    DirMapas = Lector.GetValue("RUTAS", "Mapas")
    
    With ClientSetup
        ' VIDEO
        .byMemory = Lector.GetValue("VIDEO", "DynamicMemory")
        .OverrideVertexProcess = CByte(Lector.GetValue("VIDEO", "VertexProcessingOverride"))
        
        ' MOSTRAR
        tStr = Lector.GetValue("MOSTRAR", "LastPos") ' x-y
        UserPos.X = Val(ReadField(1, tStr, Asc("-")))
        UserPos.y = Val(ReadField(2, tStr, Asc("-")))
        frmMain.mnuVerAutomatico.Checked = Val(Lector.GetValue("MOSTRAR", "ControlAutomatico"))
        frmMain.mnuVerCapa2.Checked = Val(Lector.GetValue("MOSTRAR", "Capa2"))
        frmMain.mnuVerCapa3.Checked = Val(Lector.GetValue("MOSTRAR", "Capa3"))
        frmMain.mnuVerCapa4.Checked = Val(Lector.GetValue("MOSTRAR", "Capa4"))
        frmMain.mnuVerTranslados.Checked = Val(Lector.GetValue("MOSTRAR", "Translados"))
        frmMain.mnuVerObjetos.Checked = Val(Lector.GetValue("MOSTRAR", "Objetos"))
        frmMain.mnuVerNPCs.Checked = Val(Lector.GetValue("MOSTRAR", "NPCs"))
        frmMain.mnuVerTriggers.Checked = Val(Lector.GetValue("MOSTRAR", "Triggers"))
        frmMain.mnuVerGrilla.Checked = Val(Lector.GetValue("MOSTRAR", "Grilla")) ' Grilla
        VerGrilla = frmMain.mnuVerGrilla.Checked
        frmMain.mnuVerBloqueos.Checked = Val(Lector.GetValue("MOSTRAR", "Bloqueos"))
        frmMain.mnuVerParticulas.Checked = Val(Lector.GetValue("MOSTRAR", "Particulas"))
        frmTriggers.cVerTriggers.value = frmMain.mnuVerTriggers.Checked
        frmBloqueos.cVerBloqueos.value = frmMain.mnuVerBloqueos.Checked
        .Preview = Val(Lector.GetValue("MOSTRAR", "Preview"))
        
        ' Tamaño de visualizacion en el cliente
        ClienteHeight = Val(Lector.GetValue("MOSTRAR", "ClienteHeight"))
        ClienteWidth = Val(Lector.GetValue("MOSTRAR", "ClienteWidth"))
        
        If ClienteHeight <= 0 Then ClienteHeight = 13
        If ClienteWidth <= 0 Then ClienteWidth = 17
        
        'MAPA
        XMaxMapSize = Val(Lector.GetValue("MAPA", "XMaxMapSize"))
        XMinMapSize = Val(Lector.GetValue("MAPA", "XMinMapSize"))
        YMaxMapSize = Val(Lector.GetValue("MAPA", "yMaxMapSize"))
        YMinMapSize = Val(Lector.GetValue("MAPA", "yMinMapSize"))
        
    End With
    
    Set Lector = Nothing
    
    Exit Sub
  
fileErr:

    If Err.Number <> 0 Then
       MsgBox ("Ha ocurrido un error al cargar la configuracion del cliente. Error " & Err.Number & " : " & Err.Description)
       End 'Usar "End" en vez del Sub CloseClient() ya que todavia no se inicializa nada.
    End If
End Sub

''
' Loads grh data using the new file format.
'

Public Sub LoadGrhData()
'*************************************
'Autor: Lorwik
'Fecha: ???
'Descripción: Carga el index de Graficos
'*************************************
On Error GoTo ErrorHandler:

    Dim Grh         As Long
    Dim Frame       As Long
    Dim fileVersion As Long
    Dim LaCabecera  As tCabecera
    Dim fileBuff    As clsByteBuffer
    Dim InfoHead    As INFOHEADER
    Dim buffer()    As Byte

    InfoHead = File_Find(DirRecursos & "Scripts" & Formato, LCase$("graficos.ind"))
    
    If InfoHead.lngFileSize <> 0 Then
    
        Extract_File_Memory Scripts, LCase$("graficos.ind"), buffer()
        
        Set fileBuff = New clsByteBuffer
        
        fileBuff.initializeReader buffer
        
        LaCabecera.Desc = fileBuff.getString(Len(LaCabecera.Desc))
        LaCabecera.CRC = fileBuff.getLong
        LaCabecera.MagicWord = fileBuff.getLong
    
        fileVersion = fileBuff.getLong
        
        grhCount = fileBuff.getLong
        
        ReDim GrhData(0 To grhCount) As GrhData
        
        While Grh <> grhCount
            Grh = fileBuff.getLong

            With GrhData(Grh)
            
                '.active = True
                .NumFrames = fileBuff.getInteger
                If .NumFrames <= 0 Then GoTo ErrorHandler
                
                ReDim .Frames(1 To .NumFrames)
                
                If .NumFrames > 1 Then
                
                    For Frame = 1 To .NumFrames
                        .Frames(Frame) = fileBuff.getLong
                        If .Frames(Frame) <= 0 Or .Frames(Frame) > grhCount Then GoTo ErrorHandler
                    Next Frame
                    
                    .speed = fileBuff.getSingle
                    If .speed <= 0 Then GoTo ErrorHandler
                    
                    .pixelHeight = GrhData(.Frames(1)).pixelHeight
                    If .pixelHeight <= 0 Then GoTo ErrorHandler
                    
                    .pixelWidth = GrhData(.Frames(1)).pixelWidth
                    If .pixelWidth <= 0 Then GoTo ErrorHandler
                    
                    .TileWidth = GrhData(.Frames(1)).TileWidth
                    If .TileWidth <= 0 Then GoTo ErrorHandler
                    
                    .TileHeight = GrhData(.Frames(1)).TileHeight
                    If .TileHeight <= 0 Then GoTo ErrorHandler
                    
                Else
                    
                    .FileNum = fileBuff.getLong
                    If .FileNum <= 0 Then GoTo ErrorHandler
                    
                    .pixelWidth = fileBuff.getInteger
                    If .pixelWidth <= 0 Then GoTo ErrorHandler
                    
                    .pixelHeight = fileBuff.getInteger
                    If .pixelHeight <= 0 Then GoTo ErrorHandler
                    
                    .sX = fileBuff.getInteger
                    If .sX < 0 Then GoTo ErrorHandler
                    
                    .sY = fileBuff.getInteger
                    If .sY < 0 Then GoTo ErrorHandler
                    
                    .TileWidth = .pixelWidth / TilePixelHeight
                    .TileHeight = .pixelHeight / TilePixelWidth
                    
                    .Frames(1) = Grh
                    
                End If
                
            End With
            
        Wend
        
        Erase buffer
    End If
    
    Set fileBuff = Nothing
    
Exit Sub

ErrorHandler:
    
    If Err.Number <> 0 Then
        
        If Err.Number = 53 Then
            Call MsgBox("El archivo Graficos.ind no existe. Por favor, reinstale el juego.", , Form_Caption)
            Call CloseClient
        End If
        
    End If
    
End Sub

Public Sub CargarCabezas()
'*************************************
'Autor: Lorwik
'Fecha: ???
'Descripción: Carga el index de Cabezas
'*************************************
On Error GoTo ErrHandler:

    Dim buffer()    As Byte
    Dim InfoHead    As INFOHEADER
    Dim i           As Integer
    Dim j           As Integer
    Dim LaCabecera  As tCabecera
    Dim fileBuff  As clsByteBuffer
    
    InfoHead = File_Find(DirRecursos & "Scripts" & Formato, LCase$("cabezas.ind"))
    
    If InfoHead.lngFileSize <> 0 Then
    
        Extract_File_Memory Scripts, LCase$("cabezas.ind"), buffer()
        
        Set fileBuff = New clsByteBuffer
        
        fileBuff.initializeReader buffer
        
        LaCabecera.Desc = fileBuff.getString(Len(LaCabecera.Desc))
        LaCabecera.CRC = fileBuff.getLong
        LaCabecera.MagicWord = fileBuff.getLong
        
        NumHeads = fileBuff.getInteger()  'cantidad de cabezas
    
        ReDim HeadData(0 To NumHeads) As HeadData
        ReDim Miscabezas(0 To NumHeads) As tIndiceCabeza
                      
        For i = 1 To NumHeads
        
            Miscabezas(i).Head(1) = fileBuff.getLong()
            Miscabezas(i).Head(2) = fileBuff.getLong()
            Miscabezas(i).Head(3) = fileBuff.getLong()
            Miscabezas(i).Head(4) = fileBuff.getLong()
                
            If Miscabezas(i).Head(1) Then
                Call InitGrh(HeadData(i).Head(1), Miscabezas(i).Head(1), 0)
                Call InitGrh(HeadData(i).Head(2), Miscabezas(i).Head(2), 0)
                Call InitGrh(HeadData(i).Head(3), Miscabezas(i).Head(3), 0)
                Call InitGrh(HeadData(i).Head(4), Miscabezas(i).Head(4), 0)
            End If
        Next i
        
        Erase buffer
    End If
    
    Set fileBuff = Nothing
    
ErrHandler:
    
    If Err.Number <> 0 Then
        
        If Err.Number = 53 Then
            Call MsgBox("El archivo Head.ind no existe. Por favor, reinstale el juego.", , Form_Caption)
            Call CloseClient
        End If
        
    End If
    
End Sub

Public Sub CargarCascos()
'*************************************
'Autor: Lorwik
'Fecha: ???
'Descripción: Carga el index de Cascos
'*************************************
On Error GoTo ErrHandler:

    Dim buffer()    As Byte
    Dim dLen        As Long
    Dim InfoHead    As INFOHEADER
    Dim i           As Integer
    Dim j           As Integer
    Dim LaCabecera  As tCabecera
    Dim fileBuff  As clsByteBuffer
    
    InfoHead = File_Find(DirRecursos & "Scripts" & Formato, LCase$("cascos.ind"))
    
    If InfoHead.lngFileSize <> 0 Then
    
        Extract_File_Memory Scripts, LCase$("cascos.ind"), buffer()
        
        Set fileBuff = New clsByteBuffer
        
        fileBuff.initializeReader buffer
        
        LaCabecera.Desc = fileBuff.getString(Len(LaCabecera.Desc))
        LaCabecera.CRC = fileBuff.getLong
        LaCabecera.MagicWord = fileBuff.getLong
    
        NumCascos = fileBuff.getInteger()   'cantidad de cascos
             
        ReDim CascoAnimData(0 To NumCascos) As HeadData
        ReDim Miscabezas(0 To NumCascos) As tIndiceCabeza
             
        For i = 1 To NumCascos
        
            Miscabezas(i).Head(1) = fileBuff.getLong()
            Miscabezas(i).Head(2) = fileBuff.getLong()
            Miscabezas(i).Head(3) = fileBuff.getLong()
            Miscabezas(i).Head(4) = fileBuff.getLong()
            
            If Miscabezas(i).Head(1) Then
                Call InitGrh(CascoAnimData(i).Head(1), Miscabezas(i).Head(1), 0)
                Call InitGrh(CascoAnimData(i).Head(2), Miscabezas(i).Head(2), 0)
                Call InitGrh(CascoAnimData(i).Head(3), Miscabezas(i).Head(3), 0)
                Call InitGrh(CascoAnimData(i).Head(4), Miscabezas(i).Head(4), 0)
            End If
        Next i
         
        Erase buffer
    End If
    
    Set fileBuff = Nothing
    
ErrHandler:
    
    If Err.Number <> 0 Then
        
        If Err.Number = 53 Then
            Call MsgBox("El archivo Helmet.ind no existe. Por favor, reinstale el juego.", , Form_Caption)
            Call CloseClient
        End If
        
    End If
    
End Sub

Sub CargarCuerpos()
'*************************************
'Autor: Lorwik
'Fecha: ???
'Descripción: Carga el index de Cuerpos
'*************************************
On Error GoTo ErrHandler:

    Dim buffer()    As Byte
    Dim dLen        As Long
    Dim InfoHead    As INFOHEADER
    Dim i           As Long
    Dim NumCuerpos As Integer
    Dim MisCuerpos() As tIndiceCuerpo
    Dim LaCabecera As tCabecera
    Dim fileBuff  As clsByteBuffer
    
    InfoHead = File_Find(DirRecursos & "Scripts" & Formato, LCase$("personajes.ind"))
    
    If InfoHead.lngFileSize <> 0 Then
    
        Extract_File_Memory Scripts, LCase$("personajes.ind"), buffer()
        
        Set fileBuff = New clsByteBuffer
        
        fileBuff.initializeReader buffer
        
        LaCabecera.Desc = fileBuff.getString(Len(LaCabecera.Desc))
        LaCabecera.CRC = fileBuff.getLong
        LaCabecera.MagicWord = fileBuff.getLong
    
        'num de cabezas
        NumCuerpos = fileBuff.getInteger()
    
        'Resize array
        ReDim BodyData(0 To NumCuerpos) As BodyData
        ReDim MisCuerpos(0 To NumCuerpos) As tIndiceCuerpo
    
        For i = 1 To NumCuerpos
            MisCuerpos(i).Body(1) = fileBuff.getLong()
            MisCuerpos(i).Body(2) = fileBuff.getLong()
            MisCuerpos(i).Body(3) = fileBuff.getLong()
            MisCuerpos(i).Body(4) = fileBuff.getLong()
            MisCuerpos(i).HeadOffsetX = fileBuff.getInteger()
            MisCuerpos(i).HeadOffsetY = fileBuff.getInteger()
            
            If MisCuerpos(i).Body(1) Then
                Call InitGrh(BodyData(i).Walk(1), MisCuerpos(i).Body(1), 0)
                Call InitGrh(BodyData(i).Walk(2), MisCuerpos(i).Body(2), 0)
                Call InitGrh(BodyData(i).Walk(3), MisCuerpos(i).Body(3), 0)
                Call InitGrh(BodyData(i).Walk(4), MisCuerpos(i).Body(4), 0)
                
                BodyData(i).HeadOffset.X = MisCuerpos(i).HeadOffsetX
                BodyData(i).HeadOffset.y = MisCuerpos(i).HeadOffsetY
            End If
        Next i
    
        Erase buffer
    End If
    
    Set fileBuff = Nothing
    
ErrHandler:
    
    If Err.Number <> 0 Then
        
        If Err.Number = 53 Then
            Call MsgBox("El archivo Personajes.ind no existe. Por favor, reinstale el juego.", , Form_Caption)
            Call CloseClient
        End If
        
    End If
    
End Sub

Sub CargarFxs()
'*************************************
'Autor: Lorwik
'Fecha: ???
'Descripción: Carga el index de Fxs
'*************************************
On Error GoTo ErrHandler:

    Dim buffer()    As Byte
    Dim dLen        As Long
    Dim InfoHead    As INFOHEADER
    Dim i           As Long
    Dim NumFxs      As Integer
    Dim LaCabecera  As tCabecera
    Dim fileBuff  As clsByteBuffer
    
    InfoHead = File_Find(DirRecursos & "Scripts" & Formato, LCase$("fxs.ind"))
    
    If InfoHead.lngFileSize <> 0 Then
    
        Extract_File_Memory Scripts, LCase$("fxs.ind"), buffer()
        
        Set fileBuff = New clsByteBuffer
        
        fileBuff.initializeReader buffer
        
        LaCabecera.Desc = fileBuff.getString(Len(LaCabecera.Desc))
        LaCabecera.CRC = fileBuff.getLong
        LaCabecera.MagicWord = fileBuff.getLong
    
        'num de Fxs
        NumFxs = fileBuff.getInteger()
        
        'Resize array
        ReDim FxData(0 To NumFxs) As tIndiceFx
        
        For i = 1 To NumFxs
            FxData(i).Animacion = fileBuff.getLong()
            FxData(i).OffsetX = fileBuff.getInteger()
            FxData(i).OffsetY = fileBuff.getInteger()
        Next i
    
        Erase buffer
    End If
    
    Set fileBuff = Nothing

ErrHandler:
    
    If Err.Number <> 0 Then
        
        If Err.Number = 53 Then
            Call MsgBox("El archivo Fxs.ind no existe. Por favor, reinstale el juego.", , Form_Caption)
            Call CloseClient
        End If
        
    End If

End Sub

Sub CargarAnimArmas()
'*************************************
'Autor: Lorwik
'Fecha: ???
'Descripción: Carga el index de Armas
'*************************************
On Error GoTo ErrHandler:

    Dim buffer()    As Byte
    Dim dLen        As Long
    Dim InfoHead    As INFOHEADER
    Dim i As Long
    Dim LaCabecera As tCabecera
    Dim fileBuff  As clsByteBuffer
    
    InfoHead = File_Find(DirRecursos & "Scripts" & Formato, LCase$("armas.ind"))
    
    If InfoHead.lngFileSize <> 0 Then
    
        Extract_File_Memory Scripts, LCase$("armas.ind"), buffer()
        
        Set fileBuff = New clsByteBuffer
        
        fileBuff.initializeReader buffer
        
        LaCabecera.Desc = fileBuff.getString(Len(LaCabecera.Desc))
        LaCabecera.CRC = fileBuff.getLong
        LaCabecera.MagicWord = fileBuff.getLong
    
        'num de armas
        NumWeaponAnims = fileBuff.getInteger()
        
        'Resize array
        ReDim WeaponAnimData(1 To NumWeaponAnims) As WeaponAnimData
        ReDim Weapons(1 To NumWeaponAnims) As tIndiceArmas
        
        For i = 1 To NumWeaponAnims
            Weapons(i).weapon(1) = fileBuff.getLong()
            Weapons(i).weapon(2) = fileBuff.getLong()
            Weapons(i).weapon(3) = fileBuff.getLong()
            Weapons(i).weapon(4) = fileBuff.getLong()
            
            If Weapons(i).weapon(1) Then
            
                Call InitGrh(WeaponAnimData(i).WeaponWalk(1), Weapons(i).weapon(1), 0)
                Call InitGrh(WeaponAnimData(i).WeaponWalk(2), Weapons(i).weapon(2), 0)
                Call InitGrh(WeaponAnimData(i).WeaponWalk(3), Weapons(i).weapon(3), 0)
                Call InitGrh(WeaponAnimData(i).WeaponWalk(4), Weapons(i).weapon(4), 0)
            
            End If
        Next i
    
        Erase buffer
    End If
    
    Set fileBuff = Nothing

ErrHandler:
    
    If Err.Number <> 0 Then
        
        If Err.Number = 53 Then
            Call MsgBox("El archivo Armas.ind no existe. Por favor, reinstale el juego.", , Form_Caption)
            Call CloseClient
        End If
        
    End If

End Sub

Sub CargarAnimEscudos()
'*************************************
'Autor: Lorwik
'Fecha: ???
'Descripción: Carga el index de Escudos
'*************************************
On Error GoTo ErrHandler:

    Dim buffer()    As Byte
    Dim InfoHead    As INFOHEADER
    Dim i As Long
    Dim LaCabecera As tCabecera
    Dim fileBuff  As clsByteBuffer
    
    InfoHead = File_Find(DirRecursos & "Scripts" & Formato, LCase$("escudos.ind"))
    
    If InfoHead.lngFileSize <> 0 Then
    
        Extract_File_Memory Scripts, LCase$("escudos.ind"), buffer()
        
        Set fileBuff = New clsByteBuffer
        
        fileBuff.initializeReader buffer
        
        LaCabecera.Desc = fileBuff.getString(Len(LaCabecera.Desc))
        LaCabecera.CRC = fileBuff.getLong
        LaCabecera.MagicWord = fileBuff.getLong
    
        'num de escudos
        NumEscudosAnims = fileBuff.getInteger()
        
        'Resize array
        ReDim ShieldAnimData(1 To NumEscudosAnims) As ShieldAnimData
        ReDim Shields(1 To NumEscudosAnims) As tIndiceEscudos
        
        For i = 1 To NumEscudosAnims
            Shields(i).shield(1) = fileBuff.getLong()
            Shields(i).shield(2) = fileBuff.getLong()
            Shields(i).shield(3) = fileBuff.getLong()
            Shields(i).shield(4) = fileBuff.getLong()
            
            If Shields(i).shield(1) Then
            
                Call InitGrh(ShieldAnimData(i).ShieldWalk(1), Shields(i).shield(1), 0)
                Call InitGrh(ShieldAnimData(i).ShieldWalk(2), Shields(i).shield(2), 0)
                Call InitGrh(ShieldAnimData(i).ShieldWalk(3), Shields(i).shield(3), 0)
                Call InitGrh(ShieldAnimData(i).ShieldWalk(4), Shields(i).shield(4), 0)
            
            End If
        Next i
    
        Erase buffer
    End If
    
    Set fileBuff = Nothing

ErrHandler:
    
    If Err.Number <> 0 Then
        
        If Err.Number = 53 Then
            Call MsgBox("El archivo Escudos.ind no existe. Por favor, reinstale el juego.", , Form_Caption)
            Call CloseClient
        End If
        
    End If
    
End Sub

Public Sub CargarMinimapa()

    Dim fileBuff    As clsByteBuffer
    Dim InfoHead    As INFOHEADER
    Dim buffer()    As Byte
    Dim i           As Long
    
    InfoHead = File_Find(DirRecursos & "Scripts" & Formato, LCase$("minimap.bin"))
    
    If InfoHead.lngFileSize <> 0 Then
    
        Extract_File_Memory Scripts, LCase$("minimap.bin"), buffer()
        
        Set fileBuff = New clsByteBuffer
        
        fileBuff.initializeReader buffer
        
        For i = 1 To grhCount
            If Grh_Check(i) Then
                GrhData(i).mini_map_color = fileBuff.getLong
            End If
        Next i
        
        Erase buffer
    End If
    
    Set fileBuff = Nothing
    
End Sub

Private Function Grh_Check(ByVal grh_index As Long) As Boolean
'**************************************************************
'Author: Aaron Perkins - Modified by Juan Martín Sotuyo Dodero
'Last Modify Date: 1/04/2003
'
'**************************************************************
    'check grh_index
    If grh_index > 0 And grh_index <= grhCount Then
        Grh_Check = GrhData(grh_index).NumFrames
    End If
End Function

''
' Carga los indices de Superficie
'

Public Sub CargarIndicesSuperficie()
'*************************************************
'Author: ^[GS]^
'Last modified: 29/05/06
'*************************************************

On Error GoTo Fallo
    Dim i As Integer
    
    Set Lector = New clsIniManager

    If FileExist(DirInit & "Indices.ini", vbArchive) = False Then
        MsgBox "Falta el archivo '" & DirInit & "Indices.ini'", vbCritical
        End
    End If

    Call Lector.Initialize(DirInit & "Indices.ini")
    MaxSup = Val(Lector.GetValue("INIT", "Referencias"))
    
    ReDim SupData(MaxSup) As SupData
    frmSuperficies.lListado.Clear
    
    For i = 0 To MaxSup
        SupData(i).name = Lector.GetValue("REFERENCIA" & i, "Nombre")
        SupData(i).Grh = Val(Lector.GetValue("REFERENCIA" & i, "GrhIndice"))
        SupData(i).Width = Val(Lector.GetValue("REFERENCIA" & i, "Ancho"))
        SupData(i).Height = Val(Lector.GetValue("REFERENCIA" & i, "Alto"))
        SupData(i).Block = IIf(Val(Lector.GetValue("REFERENCIA" & i, "Bloquear")) = 1, True, False)
        SupData(i).Capa = Val(Lector.GetValue("REFERENCIA" & i, "Capa"))
        frmSuperficies.lListado.AddItem SupData(i).name & " - #" & i
    Next
    
    DoEvents
    
    Set Lector = Nothing
    Exit Sub
Fallo:
    MsgBox "Error al intentar cargar el indice " & i & " de " & DirInit & "Indices.ini" & vbCrLf & "Err: " & Err.Number & " - " & Err.Description, vbCritical + vbOKOnly
End Sub

''
' Carga los indices de Triggers
'

Public Sub CargarIndicesTriggers()
    '*************************************************
    'Author: ^[GS]^
    'Last modified: 28/05/06
    '*************************************************

    On Error GoTo Fallo
    
    Dim NumT As Integer
    Dim T    As Integer
    Set Lector = New clsIniManager

    If FileExist(DirInit & "Triggers.ini", vbArchive) = False Then
        MsgBox "Falta el archivo '" & DirInit & "Triggers.ini'", vbCritical
        End
    End If
    
    Call Lector.Initialize(DirInit & "Triggers.ini")
    frmTriggers.lListado.Clear
    NumT = Val(Lector.GetValue("INIT", "NumTriggers"))

    For T = 1 To NumT
        frmTriggers.lListado.AddItem Lector.GetValue("Trig" & T, "Name") & " - #" & (T - 1)
    Next T
    
    Set Lector = Nothing

    Exit Sub
Fallo:
    MsgBox "Error al intentar cargar el Trigger " & T & " de Triggers.ini en " & DirInit & vbCrLf & "Err: " & Err.Number & " - " & Err.Description, vbCritical + vbOKOnly

End Sub

''
' Carga los indices de NPCs
'

Public Sub CargarIndicesNPC()

    '*************************************************
    'Author: Lorwik
    'Last modified: 27/04/2023
    '*************************************************
    On Error Resume Next

    'On Error GoTo Fallo
    If FileExist(DirDats & "NPCs.dat", vbArchive) = False Then
        MsgBox "Falta el archivo 'NPCs.dat' en " & DirDats, vbCritical
        Call CloseClient

    End If

    Dim Trabajando As String

    Dim NPC        As Integer

    Set Lector = New clsIniManager

    frmNpcs.lListado.Clear
    Call Lector.Initialize(DirDats & "NPCs.dat")
    NumNPCs = Val(Lector.GetValue("INIT", "NumNPCs"))
    
    ReDim NpcData(NumNPCs) As NpcData
    Trabajando = "Dats\NPCs.dat"

    For NPC = 1 To NumNPCs
        NpcData(NPC).name = Lector.GetValue("NPC" & NPC, "Name")
        
        NpcData(NPC).Body = Val(Lector.GetValue("NPC" & NPC, "Body"))
        NpcData(NPC).Head = Val(Lector.GetValue("NPC" & NPC, "Head"))
        NpcData(NPC).Heading = Val(Lector.GetValue("NPC" & NPC, "Heading"))

        If LenB(NpcData(NPC).name) <> 0 Then frmNpcs.lListado.AddItem NpcData(NPC).name & " - #" & NPC
    Next

    Set Lector = Nothing

    Exit Sub
Fallo:
    MsgBox "Error al intentar cargar el NPC " & NPC & " de " & Trabajando & " en " & DirDats & vbCrLf & "Err: " & Err.Number & " - " & Err.Description, vbCritical + vbOKOnly

End Sub

''
' Carga los indices de Objetos
'

Public Sub CargarIndicesOBJ()
    '*************************************************
    'Author: ^[GS]^
    'Last modified: 20/05/06
    '*************************************************

    On Error GoTo Fallo

    If FileExist(DirDats & "OBJ.dat", vbArchive) = False Then
        MsgBox "Falta el archivo 'OBJ.dat' en " & DirDats, vbCritical
        End

    End If

    Dim obj As Integer

    Set Lector = New clsIniManager
    
    Call Lector.Initialize(DirDats & "OBJ.dat")
    frmObjetos.lListado.Clear
    NumOBJs = Val(Lector.GetValue("INIT", "NumOBJs"))
    ReDim ObjData(1 To NumOBJs) As ObjData

    For obj = 1 To NumOBJs
        frmCargando.lblCargando.Caption = "Cargando Datos de Objetos..." & obj & "/" & NumOBJs
        DoEvents
        ObjData(obj).name = Lector.GetValue("OBJ" & obj, "Name")
        
        If LenB(ObjData(obj).name) > 0 Then
            ObjData(obj).GrhIndex = Val(Lector.GetValue("OBJ" & obj, "GrhIndex"))
            ObjData(obj).ObjType = Val(Lector.GetValue("OBJ" & obj, "ObjType"))
            ObjData(obj).Ropaje = Val(Lector.GetValue("OBJ" & obj, "NumRopaje"))
            ObjData(obj).Info = Lector.GetValue("OBJ" & obj, "Info")
            ObjData(obj).WeaponAnim = Val(Lector.GetValue("OBJ" & obj, "Anim"))
            ObjData(obj).Texto = Lector.GetValue("OBJ" & obj, "Texto")
            ObjData(obj).GrhSecundario = Val(Lector.GetValue("OBJ" & obj, "GrhSec"))
            ObjData(obj).Cerrada = Val(Lector.GetValue("OBJ" & obj, "Cerrada"))
            ObjData(obj).Subtipo = Val(Lector.GetValue("OBJ" & obj, "Subtipo"))
            frmObjetos.lListado.AddItem ObjData(obj).name & " - #" & obj

        End If

    Next obj
    
    Set Lector = Nothing

    Exit Sub
Fallo:
    MsgBox "Error al intentar cargar el Objteto " & obj & " de OBJ.dat en " & DirDats & vbCrLf & "Err: " & Err.Number & " - " & Err.Description, vbCritical + vbOKOnly

End Sub
