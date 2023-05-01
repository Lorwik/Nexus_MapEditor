VERSION 5.00
Begin VB.Form frmNpcs 
   BackColor       =   &H80000006&
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Npc's"
   ClientHeight    =   4965
   ClientLeft      =   9525
   ClientTop       =   9210
   ClientWidth     =   4110
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4965
   ScaleWidth      =   4110
   ShowInTaskbar   =   0   'False
   Begin VB.ListBox lListado 
      Appearance      =   0  'Flat
      BackColor       =   &H80000012&
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000014&
      Height          =   3180
      ItemData        =   "frmNpcs.frx":0000
      Left            =   0
      List            =   "frmNpcs.frx":0002
      TabIndex        =   5
      Tag             =   "-1"
      Top             =   0
      Width           =   4125
   End
   Begin VB.ComboBox cNPC 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000E&
      ForeColor       =   &H80000012&
      Height          =   315
      Left            =   1380
      TabIndex        =   4
      Top             =   3690
      Width           =   2595
   End
   Begin VB.ComboBox cFiltro 
      BackColor       =   &H8000000E&
      ForeColor       =   &H80000012&
      Height          =   315
      ItemData        =   "frmNpcs.frx":0004
      Left            =   690
      List            =   "frmNpcs.frx":0006
      TabIndex        =   3
      Top             =   3300
      Width           =   3285
   End
   Begin Nexus_MapEditor.lvButtons_H cQuitarNpc 
      Height          =   345
      Left            =   120
      TabIndex        =   0
      Top             =   4530
      Width           =   1935
      _extentx        =   3413
      _extenty        =   609
      caption         =   "Quitar NPC's"
      capalign        =   2
      backstyle       =   2
      cgradient       =   0
      font            =   "frmNpcs.frx":0008
      mode            =   1
      value           =   0
      cback           =   -2147483633
   End
   Begin Nexus_MapEditor.lvButtons_H cAgregarFuncalAzar 
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Top             =   4110
      Width           =   1935
      _extentx        =   3413
      _extenty        =   661
      caption         =   "Insertar NPC's al azar"
      capalign        =   2
      backstyle       =   2
      cgradient       =   0
      font            =   "frmNpcs.frx":0030
      mode            =   1
      value           =   0
      cback           =   -2147483633
   End
   Begin Nexus_MapEditor.lvButtons_H cInsertarFunc 
      Height          =   765
      Left            =   2130
      TabIndex        =   2
      Top             =   4110
      Width           =   1845
      _extentx        =   3254
      _extenty        =   1349
      caption         =   "Insertar NPC"
      capalign        =   2
      backstyle       =   2
      cgradient       =   0
      font            =   "frmNpcs.frx":0058
      mode            =   1
      value           =   0
      cback           =   -2147483633
   End
   Begin VB.Label lbFiltrar 
      AutoSize        =   -1  'True
      BackColor       =   &H80000012&
      BackStyle       =   0  'Transparent
      Caption         =   "Filtrar:"
      ForeColor       =   &H8000000E&
      Height          =   195
      Index           =   0
      Left            =   90
      TabIndex        =   7
      Top             =   3360
      Width           =   480
   End
   Begin VB.Label lbnNPC 
      AutoSize        =   -1  'True
      BackColor       =   &H80000012&
      BackStyle       =   0  'Transparent
      Caption         =   "Numero del NPC:"
      ForeColor       =   &H8000000E&
      Height          =   195
      Left            =   90
      TabIndex        =   6
      Top             =   3780
      Width           =   1215
   End
End
Attribute VB_Name = "frmNpcs"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cFiltro_LostFocus()
    '*************************************************
    'Author: ^[GS]^
    'Last modified: 20/05/06
    '*************************************************
    
    On Error GoTo cFiltro_LostFocus_Err
    
    HotKeysAllow = True

    
    Exit Sub

cFiltro_LostFocus_Err:
    Call LogError(Err.Number, Err.Description, "FrmNpcs.cFiltro_LostFocus", Erl)
    Resume Next
    
End Sub

Private Sub cInsertarFunc_Click()
    '*************************************************
    'Author: ^[GS]^
    'Last modified: 20/05/06
    '*************************************************
    
    On Error GoTo cInsertarFunc_Click_Err
    
    If cInsertarFunc.value = True Then
        cQuitarNpc.Enabled = False
        cAgregarFuncalAzar.Enabled = False

        Call modPaneles.EstSelectPanel(3, True)
    Else
        cQuitarNpc.Enabled = True
        cAgregarFuncalAzar.Enabled = True

        Call modPaneles.EstSelectPanel(3, False)

    End If

    Exit Sub

cInsertarFunc_Click_Err:
    Call LogError(Err.Number, Err.Description, "FrmNpcs.cInsertarFunc_Click", Erl)
    Resume Next
    
End Sub

Private Sub cQuitarNpc_Click()
    '*************************************************
    'Author: ^[GS]^
    'Last modified: 20/05/06
    '*************************************************
    
    On Error GoTo cQuitarNpc_Click_Err
    
    If cQuitarNpc.value = True Then
        cInsertarFunc.Enabled = False
        cAgregarFuncalAzar.Enabled = False
        cNPC.Enabled = False
        cFiltro.Enabled = False
        lListado.Enabled = False
        Call modPaneles.EstSelectPanel(0, True)
    Else
        cInsertarFunc.Enabled = True
        cAgregarFuncalAzar.Enabled = True
        cNPC.Enabled = True
        cFiltro.Enabled = True
        lListado.Enabled = True
        Call modPaneles.EstSelectPanel(0, False)

    End If

    
    Exit Sub

cQuitarNpc_Click_Err:
    Call LogError(Err.Number, Err.Description, "FrmObjetos.cQuitarNpc_Click", Erl)
    Resume Next
    
End Sub

Private Sub cAgregarFuncalAzar_Click()
    '*************************************************
    'Author: ^[GS]^
    'Last modified: 20/05/06
    '*************************************************
    
    On Error GoTo cAgregarFuncalAzar_Click_Err

    cAgregarFuncalAzar.Enabled = False
    Call PonerAlAzar(1, 2)
    cAgregarFuncalAzar.Enabled = True
    
    Exit Sub

cAgregarFuncalAzar_Click_Err:
    Call LogError(Err.Number, Err.Description, "FrmNpcs.cAgregarFuncalAzar_Click", Erl)
    Resume Next
    
End Sub

Private Sub lListado_Click()
    '*************************************************
    'Author: Lorwik
    'Last modified: 29/04/2023
    '*************************************************
    cNPC.Text = ReadField(2, lListado.Text, Asc("#"))
End Sub
