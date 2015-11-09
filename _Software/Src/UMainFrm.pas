unit UMainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Controls.Presentation, FMX.MultiView, FMX.StdCtrls, FMX.ListBox,
  FMX.Layouts, FMX.ScrollBox, FMX.Memo, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.Objects, FMX.Edit, FMX.ExtCtrls
  , FMX.Ani
  , S4.ImageViewer
  , S4.ImageViewer.Controller
  ;

type
  TPlatformServicesRecord = record
    Service: String;
    Name: String;
  end;

//type
//  TS4ImageViewerHack = class(TCustomScrollBox);


type
  TForm1 = class(TForm)
    MultiView1: TMultiView;
    TabControlMain: TTabControl;
    PanelFooter: TPanel;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Button1: TButton;
    ListBox1: TListBox;
    ListBoxItem01_PathInfo: TListBoxItem;
    ListBoxItem02_SysInfo: TListBoxItem;
    TabItem3: TTabItem;
    Button2: TButton;
    ListViewPathInfo: TListView;
    TabItem4: TTabItem;
    ListViewSysInfo: TListView;
    ListBoxItem03_TakePhoto: TListBoxItem;
    Panel1: TPanel;
    Button3: TButton;
    Layout1: TLayout;
    EditPhotoSize: TEdit;
    Layout2: TLayout;
    Text1: TText;
    Panel2: TPanel;
    TextPhotoResult: TText;
    ImageViewer1: TImageViewer;
    TextPhotoHitData: TText;
    procedure ListBox1ItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);


  private
    { Private declarations }
    FTabFkt: TProc;

    //
    // ImageViewer1 stuff
    //
    FImageViewController : TS4ImageViewController;
    IImageViewer: IS4ImageViewer;


    procedure TabControl_ChangeTo(const Item: TListBoxItem);

    procedure TabControl_Refresh;

    procedure TabControl_Refresh_PathInfo;
    procedure TabControl_Refresh_SysInfo;
    procedure TabControl_Refresh_TakePhoto;


  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

Uses
    System.IOUtils
  , System.Rtti
  , System.Math
  , FMX.InertialMovement
  , FMX.Platform
  , FMX.MediaLibrary
  , S4.Types
  , S4.Media.Photo
  ;

const
  MaxServices = 21;
  PlatformServicesArray: array[0..MaxServices-1] of TPlatformServicesRecord =
  (
    (Service: 'FMX.Platform.IFMXApplicationService'; Name: 'Application Service'),
    (Service: 'FMX.Forms.IFMXWindowService'; Name: 'Window Service'),
    (Service: 'FMX.Forms.IFMXWindowBorderService'; Name: 'Window Border Service'),
    (Service: 'FMX.Types.IFMXTimerService'; Name: 'Timer Service'),
    (Service: 'FMX.Platform.IFMXDialogService'; Name: 'Dialog Service'),
    (Service: 'FMX.Platform.IFMXCanvasService'; Name: 'Canvas Service'),
    (Service: 'FMX.Platform.IFMXContextService'; Name: 'Context Service'),
    (Service: 'FMX.Menus.IFMXMenuService'; Name: 'Menu Service'),
    (Service: 'FMX.Platform.IFMXLocaleService'; Name: 'Locale Service'),
    (Service: 'FMX.Platform.IFMXClipboardService'; Name: 'Clipboard Service'),
    (Service: 'FMX.Types.IFMXCursorService'; Name: 'Cursor Service'),
    (Service: 'FMX.Platform.IFMXDeviceService'; Name: 'Device Service'),
    (Service: 'FMX.Platform.IFMXDragDropService'; Name: 'Drag&Drop Service'),
    (Service: 'FMX.Platform.IFMXHideAppService'; Name: 'Hide App Service'),
    (Service: 'FMX.Types.IFMXMouseService'; Name: 'Mouse Service'),
    (Service: 'FMX.Pickers.IFMXPickerService'; Name: 'Picker Service'),
    (Service: 'FMX.Platform.IFMXScreenService'; Name: 'Screen Service'),
    (Service: 'FMX.Platform.IFMXStyleService'; Name: 'Style Service'),
    (Service: 'FMX.Platform.IFMXSystemFontsService'; Name: 'System Fonts Service'),
    (Service: 'FMX.Platform.IFMXTextService'; Name: 'Text Service'),
    (Service: 'FMX.Platform.IFMXVirtualKeyboardService'; Name: 'Virtual Keyboard Service')
  );


procedure TForm1.Button2Click(Sender: TObject);
begin
  TabControl_Refresh;
end;







procedure TForm1.Button3Click(Sender: TObject);
begin

  TS4Media_TakePhoto.Execute(TSize.Create(EditPhotoSize.Text.ToInteger,
                                          EditPhotoSize.Text.ToInteger),
                             False //Do not store in Album
                             // Image ready
                             , procedure (const bmpPhoto : TBitmap)
                             begin

                               IImageViewer.Bitmap := bmpPhoto;

//                               ImageViewer1.Bitmap.Assign(bmpPhoto);
//
//                               TextPhotoResult.Text := 'Result W: ' +          bmpPhoto.Width.ToString  +
//                                                       ', H: '      +          bmpPhoto.Height.ToString +
//                                                       Format(' Scale %1.4f', [bmpPhoto.BitmapScale])
//                                                       ;
//
//                               Bitmap_Changed(bmpPhoto.Width, bmpPhoto.Height);

                             end
                             // Image cancelled
                             , procedure
                             begin
                               IImageViewer.Bitmap_Clear;// := nil;

                               ShowMessage('Take Photo was cancelled');
                             end
                            );


end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TabControlMain.TabPosition := TTabPosition.None;
  TabControlMain.TabIndex    := 0;
  FTabFkt                    := nil;

  FImageViewController := TS4ImageViewController.Create( ImageViewer1 );
  IImageViewer         := FImageViewController; // From now on this is my access interface
  IImageViewer.SetScaleLimits(IImageViewer.ScaleMin, // TS4ImageViewController. ScaleMin,
                              100);
  IImageViewer.OnViewportChanged :=  procedure (Arg1, Arg2, Arg3 : Single)
                                  begin
                 TextPhotoHitData.Text := Format('VP.X: %4.0f, Y: %4.0f, Scale %1.3f', [Arg1, Arg2, Arg3]);
                                  end;

  IImageViewer.OnBitmapChanged :=  procedure (Arg1, Arg2, Arg3 : Single)
                                  begin
                 TextPhotoResult.Text := Format('Bmp.W: %4.0f, H: %4.0f, Scale %1.3f', [Arg1, Arg2, Arg3]);
                                  end;

  IImageViewer.OnSelectionChanged :=  procedure (Arg1, Arg2, Arg3 : Single)
                                  begin
                                    if  Arg3 > 0.0 then
                 TextPhotoHitData.Text := Format('Sel.X: %4.0f, Y: %4.0f, DRAW', [Arg1, Arg2])
  else
                 TextPhotoHitData.Text := Format('Sel.X: %4.0f, Y: %4.0f',       [Arg1, Arg2]);
                                  end;


end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  IImageViewer         := nil;
  FImageViewController.Free;
  FImageViewController := nil;
end;

procedure TForm1.TabControl_ChangeTo(const Item: TListBoxItem);
begin
  MultiView1.HideMaster;

  TabControlMain.TabIndex := Item.Index + 1;

  if      Item = ListBoxItem01_PathInfo then
  begin
     FTabFkt := TabControl_Refresh_PathInfo;
  end
  else if Item = ListBoxItem02_SysInfo then
  begin
     FTabFkt := TabControl_Refresh_SysInfo;
  end
  else if Item = ListBoxItem03_TakePhoto then
  begin
     FTabFkt := TabControl_Refresh_TakePhoto;
  end;

end;

procedure TForm1.TabControl_Refresh;
begin
  if Assigned(FTabFkt) then
    FTabFkt;
end;

procedure TForm1.TabControl_Refresh_PathInfo;
var
  li: TListViewItem;
begin
  ListViewPathInfo.Items.Clear;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetRandomFileName';
  li.Detail := TPath.GetRandomFileName;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetTempFileName';
  li.Detail := TPath.GetTempFileName;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetTempPath';
  li.Detail := TPath.GetTempPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetHomePath';
  li.Detail := TPath.GetHomePath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetDocumentsPath';
  li.Detail := TPath.GetDocumentsPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetSharedDocumentsPath';
  li.Detail := TPath.GetSharedDocumentsPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetLibraryPath';
  li.Detail := TPath.GetLibraryPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetCachePath';
  li.Detail := TPath.GetCachePath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetPublicPath';
  li.Detail := TPath.GetPublicPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetPicturesPath';
  li.Detail := TPath.GetPicturesPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetSharedPicturesPath';
  li.Detail := TPath.GetSharedPicturesPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetCameraPath';
  li.Detail := TPath.GetCameraPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetSharedCameraPath';
  li.Detail := TPath.GetSharedCameraPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetMusicPath';
  li.Detail := TPath.GetMusicPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetSharedMusicPath';
  li.Detail := TPath.GetSharedMusicPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetMoviesPath';
  li.Detail := TPath.GetMoviesPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetSharedMoviesPath';
  li.Detail := TPath.GetSharedMoviesPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetAlarmsPath';
  li.Detail := TPath.GetAlarmsPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetSharedAlarmsPath';
  li.Detail := TPath.GetSharedAlarmsPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetDownloadsPath';
  li.Detail := TPath.GetDownloadsPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetSharedDownloadsPath';
  li.Detail := TPath.GetSharedDownloadsPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetRingtonesPath';
  li.Detail := TPath.GetRingtonesPath;

  li := ListViewPathInfo.Items.Add;
  li.Text   := 'TPath.GetSharedRingtonesPath';
  li.Detail := TPath.GetSharedRingtonesPath;

end;







procedure TForm1.TabControl_Refresh_SysInfo;
var
  li: TListViewItem;
  LService: TPlatformServicesRecord;
  LRttiContext : TRttiContext;
  LRttiType    : TRttiType;
  IScreenService: IFMXScreenService;
  IApplicationService: IFMXApplicationService;
  IDeviceService: IFMXDeviceService;
  IDeviceMetricsService: IFMXDeviceMetricsService;
  ISystemFontService: IFMXSystemFontService;
  IMultiDisplayService: IFMXMultiDisplayService;
  I: Integer;
  ILocaleService: IFMXLocaleService;
  ISystemInfoService: IFMXSystemInformationService;

const
  LFormatString: String = '[%s] %s';
  ServiceAvailable: array[Boolean] of String = ('Not Available', 'Available');

type
  TDeviceClass = (Unknown, Desktop, Phone, MediaPlayer, Tablet, Automotive, Industrial, Embedded, Watch, Glasses, Elf, Dwarf, Wizard);


begin
  ListViewSysInfo.Items.Clear;

  li         := ListViewSysInfo.Items.Add;
  li.Purpose := TListItemPurpose.Header;
  li.Text    := 'PlatformServices check';


  LRttiType := nil;

  LRttiContext := TRttiContext.Create;
  try

    for LService in PlatformServicesArray do
    begin
      LRttiType := LRttiContext.FindType(LService.Service);

      li := ListViewSysInfo.Items.Add;
      li.Text   := LService.Name;

      if Assigned(LRttiType) then
      begin
        li.Detail := Format(LFormatString,
               [ServiceAvailable[TPlatformServices.Current.SupportsPlatformService(TRttiInterfaceType(LRttiType).GUID)],
                LService.Service])
      end
      else
      begin
        li.Detail := Format(LFormatString,
               [ServiceAvailable[False], LService.Service,
                LService.Service])
      end;

    end;

  finally
    LRttiContext.Free;
    LRttiType.Free;

  end;


  if TPlatformServices.Current.SupportsPlatformService(
       IFMXScreenService, IInterface(IScreenService)) then
  begin

    li         := ListViewSysInfo.Items.Add;
    li.Purpose := TListItemPurpose.Header;
    li.Text    := 'ScreenService details';

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetScreenSize';
    li.Detail  := Format('X: %1.0f, Y: %1.0f', [IScreenService.GetScreenSize.X, IScreenService.GetScreenSize.Y]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetScreenScale';
    li.Detail  := Format('Scale: %1.6f', [IScreenService.GetScreenScale]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetScreenOrientation';
    case IScreenService.GetScreenOrientation of
      TScreenOrientation.Portrait:          li.Detail  := 'Portrait';
      TScreenOrientation.Landscape:         li.Detail  := 'Landscape';
      TScreenOrientation.InvertedPortrait:  li.Detail  := 'InvPortrait';
      TScreenOrientation.InvertedLandscape: li.Detail  := 'InvLandscape';
    end;

    IScreenService := nil;
  end;


  if TPlatformServices.Current.SupportsPlatformService(
       IFMXApplicationService, IInterface(IApplicationService)) then
  begin

    li         := ListViewSysInfo.Items.Add;
    li.Purpose := TListItemPurpose.Header;
    li.Text    := 'ApplicationService details';

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'Title';
    li.Detail  := IApplicationService.Title;

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'DefaultTitle';
    li.Detail  := IApplicationService.DefaultTitle;

    IApplicationService := nil;
  end;



  if TPlatformServices.Current.SupportsPlatformService(
       IFMXDeviceService, IInterface(IDeviceService)) then
  begin

    li         := ListViewSysInfo.Items.Add;
    li.Purpose := TListItemPurpose.Header;
    li.Text    := 'DeviceService details';

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetModel';
    li.Detail  := IDeviceService.GetModel;

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'Features';
    if TDeviceFeature.HasTouchScreen in IDeviceService.GetFeatures then
      li.Detail  := 'HasTouchScreen';

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'DeviceClass';
    case TDeviceClass( IDeviceService.GetDeviceClass ) of
      TDeviceClass.Unknown: li.Detail  := 'Unknown';
      TDeviceClass.Desktop: li.Detail  := 'Desktop';
      TDeviceClass.Phone  : li.Detail  := 'Phone';
      TDeviceClass.MediaPlayer: li.Detail  := 'MediaPlayer';
      TDeviceClass.Tablet : li.Detail  := 'Tablet';
      TDeviceClass.Automotive: li.Detail  := 'Automotive';
      TDeviceClass.Industrial: li.Detail  := 'Industrial';
      TDeviceClass.Embedded: li.Detail  := 'Embedded';
      TDeviceClass.Watch: li.Detail  := 'Watch';
      TDeviceClass.Glasses: li.Detail  := 'Glasses';
      TDeviceClass.Elf: li.Detail  := 'Elf';
      TDeviceClass.Dwarf: li.Detail  := 'Dwarf';
      TDeviceClass.Wizard: li.Detail  := 'Wizard';
    end;


    IDeviceService := nil;
  end;


  if TPlatformServices.Current.SupportsPlatformService(
       IFMXDeviceMetricsService, IInterface(IDeviceMetricsService)) then
  begin

    li         := ListViewSysInfo.Items.Add;
    li.Purpose := TListItemPurpose.Header;
    li.Text    := 'DeviceMetricsService details';

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'PhysicalScreenSize';
    li.Detail  := Format('X: %d, Y: %d', [IDeviceMetricsService.GetDisplayMetrics.PhysicalScreenSize.cx,
                                                IDeviceMetricsService.GetDisplayMetrics.PhysicalScreenSize.cy]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'LogicalScreenSize';
    li.Detail  := Format('X: %d, Y: %d', [IDeviceMetricsService.GetDisplayMetrics.LogicalScreenSize.cx,
                                                IDeviceMetricsService.GetDisplayMetrics.LogicalScreenSize.cy]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'RawScreenSize';
    li.Detail  := Format('X: %d, Y: %d', [IDeviceMetricsService.GetDisplayMetrics.RawScreenSize.cx,
                                                IDeviceMetricsService.GetDisplayMetrics.RawScreenSize.cy]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'AspectRatio';
    li.Detail  := Format('Aspect: %1.6f', [IDeviceMetricsService.GetDisplayMetrics.AspectRatio]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'PixelsPerInch';
    li.Detail  := Format('PPI: %d', [IDeviceMetricsService.GetDisplayMetrics.PixelsPerInch]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'ScreenScale';
    li.Detail  := Format('Scale: %1.6f', [IDeviceMetricsService.GetDisplayMetrics.ScreenScale]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'FontScale';
    li.Detail  := Format('Scale: %1.6f', [IDeviceMetricsService.GetDisplayMetrics.FontScale]);

    IDeviceMetricsService := nil;
  end;



  if TPlatformServices.Current.SupportsPlatformService(
       IFMXSystemFontService, IInterface(ISystemFontService)) then
  begin

    li         := ListViewSysInfo.Items.Add;
    li.Purpose := TListItemPurpose.Header;
    li.Text    := 'SystemFontService details';

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetDefaultFontFamilyName';
    li.Detail  := ISystemFontService.GetDefaultFontFamilyName;

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetDefaultFontSize';
    li.Detail  := Format('Size: %1.6f', [ISystemFontService.GetDefaultFontSize]);

    ISystemFontService := nil;
  end;




  if TPlatformServices.Current.SupportsPlatformService(
       IFMXMultiDisplayService, IInterface(IMultiDisplayService)) then
  begin

    li         := ListViewSysInfo.Items.Add;
    li.Purpose := TListItemPurpose.Header;
    li.Text    := 'MultiDisplayService details';

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'DisplayCount';
    li.Detail  := Format('Count: %d', [IMultiDisplayService.DisplayCount]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'WorkAreaRect';
    li.Detail  := Format('L: %d, T: %d, R: %d, B: %d', [IMultiDisplayService.WorkAreaRect.Left,
                                                                    IMultiDisplayService.WorkAreaRect.Top,
                                                                    IMultiDisplayService.WorkAreaRect.Right,
                                                                    IMultiDisplayService.WorkAreaRect.Bottom
                                                                   ]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'DesktopRect';
    li.Detail  := Format('L: %d, T: %d, R: %d, B: %d', [IMultiDisplayService.DesktopRect.Left,
                                                                    IMultiDisplayService.DesktopRect.Top,
                                                                    IMultiDisplayService.DesktopRect.Right,
                                                                    IMultiDisplayService.DesktopRect.Bottom
                                                                   ]);

    for I := 0 to IMultiDisplayService.DisplayCount-1 do
    begin
      li         := ListViewSysInfo.Items.Add;
      li.Purpose := TListItemPurpose.Header;
      li.Text    := 'Display ' + I.ToString + ':';

      li         := ListViewSysInfo.Items.Add;
      li.Text    := 'Primary';
      li.Detail  := Format('%s', [IMultiDisplayService.Displays[I].Primary.ToString ]);

//      li         := ListViewSysInfo.Items.Add;
//      li.Text    := 'Primary';
//      li.Detail  := Format('%s', [IMultiDisplayService.Displays[I].BoundsRect.to .ToString ]);

    end;


    IMultiDisplayService := nil;
  end;




  if TPlatformServices.Current.SupportsPlatformService(
       IFMXLocaleService, IInterface(ILocaleService)) then
  begin

    li         := ListViewSysInfo.Items.Add;
    li.Purpose := TListItemPurpose.Header;
    li.Text    := 'LocaleService details';

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetCurrentLangID';
    li.Detail  := 'ID: ' + ILocaleService.GetCurrentLangID;

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetFirstWeekday';
    li.Detail  := 'Day: ' + ILocaleService.GetFirstWeekday.ToString;


    ILocaleService := nil;
  end;



  if TPlatformServices.Current.SupportsPlatformService(
       IFMXSystemInformationService, IInterface(ISystemInfoService)) then
  begin

    li         := ListViewSysInfo.Items.Add;
    li.Purpose := TListItemPurpose.Header;
    li.Text    := 'SystemInformationService details';

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetMinScrollThumbSize';
    li.Detail  := Format('Size: %1.0f', [ISystemInfoService.GetMinScrollThumbSize]);

    li         := ListViewSysInfo.Items.Add;
    li.Text    := 'GetCaretWidth';
    li.Detail  := Format('Size: %d', [ISystemInfoService.GetCaretWidth]);

    ISystemInfoService := nil;
  end;


end;



procedure TForm1.TabControl_Refresh_TakePhoto;
begin
  IImageViewer.Arrange_BestFit;
end;





procedure TForm1.ListBox1ItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  TabControl_ChangeTo( Item );
end;

end.
