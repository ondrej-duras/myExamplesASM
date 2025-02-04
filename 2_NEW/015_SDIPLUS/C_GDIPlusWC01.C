/* ----------------------------------------------------------------------------
   -       TITULO  : Loading GIFs with GDI+ W-TinyC                           -
   -----                                                                  -----
   -       AUTOR   : Alfonso Víctor Caballero Hurtado                         -
   -----                                                                  -----
   -       VERSION : 1.0                                                      -
   -----                                                                  -----
   -      (c) 2016. Abre los Ojos a Win32                                     -
   ---------------------------------------------------------------------------- */

#include <windows.h>
#include <winnt.h>

#define cdXPos          128
#define cdYPos          128
#define cdXSize         200
#define cdYSize         100
#define cdColFondo      0        // COLOR_BTNFACE + 1
#define cdVBarTipo      0
#define cdVBtnTipo      WS_VISIBLE+WS_OVERLAPPEDWINDOW
#define cdMainIcon      100
#define cdIdTimer       1
#define Ok              0
#define PropertyTagFrameDelay  0x5100

// Prototipos de funciones
static LRESULT WINAPI MainWndProc(HWND, UINT, WPARAM, LPARAM);

typedef unsigned long PROPID;
typedef struct {
  unsigned int       Data1;
  unsigned short     Data2;
  unsigned short     Data3;
  unsigned char      car[8];
} stFrameDimTime; 

typedef struct {
    UINT32 GdiplusVersion;             // Must be 1  (or 2 for the Ex version)
    UINT32 DebugEventCallback; // Ignored on free builds
    BOOL SuppressBackgroundThread;     // FALSE unless you're prepared to call 
                                       // the hook/unhook functions properly
    BOOL SuppressExternalCodecs;       // FALSE unless you want GDI+ only to use
                                       // its internal image codecs.
}  GdiplusStartupInput;

// Constantes globales
const char           szTitulo[] = "Cargar gif con gdi+ - TinyC";
const char           szNombreClase[] = "CargarGIFconGDI+";
// Variables globales
HWND                 hMainWnd;
WCHAR               *szfilename = L"../Res/movingwizard.gif";
ULONG_PTR            gdiplusToken;
UINT                 nWidth, nHeight;
int                  vdxClient, vdyClient;
UINT                 nFrameCount, nFramePosition;
UINT                *pPropertyItem;
UINT                *g_image;
stFrameDimTime       FrameDimensionTime = {0x6AEDBD6D,0x3FB5,0x418A,{0x83,0xA6,0x7F,0x45,0x22,0x9D,0xC8,0x72}};
stFrameDimTime      *pFrameDimTime = &FrameDimensionTime;
GdiplusStartupInput  gsi;

BOOL TestForAnimatedGIF(UINT * image) {
  /* Get the number of frame dimensions in this image */
  UINT count = 0;
  GdipImageGetFrameDimensionsCount(image, &count);
  if (!count) return FALSE;

  /* Get the list of frame dimensions from the Image object. */
  GUID * pDimensionIDs = GdipAlloc(count * sizeof(GUID));
  if (Ok != GdipImageGetFrameDimensionsList(image, pDimensionIDs, count))
    return FALSE;

  /* Get the number of frames in the first dimension. */
  if (Ok != GdipImageGetFrameCount(image, &pDimensionIDs[0], &nFrameCount))
    return FALSE;

  /* Assume that the image has a property item of type PropertyItemEquipMake.
   * Get the size of that property item. */
  UINT nSize;
  if (Ok != GdipGetPropertyItemSize(image, PropertyTagFrameDelay, &nSize))
    return FALSE;

  /* Allocate a buffer to receive the property item. */
  pPropertyItem = GdipAlloc(nSize * sizeof(PROPID));

  if (Ok != GdipGetPropertyItem(image, PropertyTagFrameDelay, nSize, pPropertyItem))
    return FALSE;

  GdipFree(pDimensionIDs);

  return (nFrameCount > 1);
}

void DrawFrameGIF (HDC hdc, UINT * image) {
  UINT *graphics;
  
  // GUID pageGuid = FrameDimensionTime;

  if (Ok!=GdipGetImageWidth (image, &nWidth) || Ok!=GdipGetImageHeight(image, &nHeight))
    return;

  GdipCreateFromHDC(hdc, &graphics);
  GdipDrawImageRectI(graphics, image, 
      0, 0,     // x-top, y-top donde pondremos la imagen
      vdxClient,
      vdyClient) ;

  GdipDeleteGraphics(graphics);
  GdipImageSelectActiveFrame(image, pFrameDimTime, nFramePosition++);

  if (nFramePosition == nFrameCount) nFramePosition = 0;
}

BOOL LoadAnimGif(const WCHAR * filename) {
  if(GdipLoadImageFromFile(filename, &g_image) != Ok) return FALSE;
  if(!TestForAnimatedGIF(g_image)) return FALSE;
  return TRUE;
}
  
static LRESULT CALLBACK MainWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
  HDC          hdc;
  PAINTSTRUCT  ps ;
  switch (message) {
    default:
         return DefWindowProc(hWnd, message, wParam, lParam);
    case WM_CHAR:
         if (wParam == VK_ESCAPE) goto wmDestroy;
         break;
    case WM_PAINT :
         hdc = BeginPaint(hWnd, &ps);
         DrawFrameGIF(hdc, g_image);
         EndPaint(hWnd, &ps);
         break;
    case WM_SIZE:
         vdxClient = LOWORD (lParam) ;
         vdyClient = HIWORD (lParam) ;
         break;
    case WM_TIMER :
         InvalidateRect (hWnd, NULL, FALSE) ;
         break;
    case WM_CREATE:
         nFramePosition = 0;
         SetTimer (hWnd, cdIdTimer, 100, NULL) ;
         break;
    case WM_DESTROY :
         wmDestroy:
         if(g_image) GdipDisposeImage(g_image);
         if(pPropertyItem) GdipFree(pPropertyItem);
         DestroyWindow (hWnd);
         PostQuitMessage(0);
         break ;
  }
  return 0 ;
}

int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    PSTR szCmdLine, int iCmdShow)
{
  MSG          msg ;
  WNDCLASS     wndclass ;
  POINT        ptDiff;    // Para calcular nuevo tamaño de Wnd
  RECT         rctWnd, rctClient;
  
  GdiplusStartup(&gdiplusToken, &gsi, NULL);
  
  wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
  wndclass.lpfnWndProc   = (WNDPROC) MainWndProc ;
  wndclass.cbClsExtra    = 0 ;
  wndclass.cbWndExtra    = 0 ;
  wndclass.hbrBackground = (HBRUSH) cdColFondo;
  wndclass.lpszMenuName  = NULL ;
  wndclass.lpszClassName = szNombreClase ;
  wndclass.hInstance     = hInstance; //GetModuleHandle (NULL) ;
  wndclass.hIcon         = LoadIcon(hInstance, (LPCTSTR) cdMainIcon);
  wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
  
  if (!LoadAnimGif(szfilename)) {
    MessageBox (NULL, TEXT ("No se pudo cargar el fichero gif"),
                 TEXT ("Error"), MB_ICONERROR) ;
    return FALSE;
  }
  if (Ok!=GdipGetImageWidth (g_image, &nWidth) || Ok!=GdipGetImageHeight(g_image, &nHeight)) {
    MessageBox (NULL, TEXT ("Dimensiones incorrectas del fichero gif"),
                 TEXT ("Error"), MB_ICONERROR) ;
    return FALSE;
  }
  if (!RegisterClass (&wndclass)) {
    MessageBox (NULL, TEXT ("No se registró correctamente la clase principal"),
                TEXT ("Error"), MB_ICONERROR) ;
    return 0 ;
  }
  
  hMainWnd = CreateWindow (szNombreClase,
                       szTitulo,
                       cdVBtnTipo,
                       cdXPos, cdYPos,
                       cdXSize, cdYSize,
                       NULL, NULL, hInstance, NULL) ;
  if (!hMainWnd) return FALSE;
  
  GetClientRect(hMainWnd, &rctClient);
  GetWindowRect(hMainWnd, &rctWnd);
  ptDiff.x = (rctWnd.right - rctWnd.left) - rctClient.right;
  ptDiff.y = (rctWnd.bottom - rctWnd.top) - rctClient.bottom;
  MoveWindow (hMainWnd,cdXPos, cdYPos, nWidth + ptDiff.x, nHeight + ptDiff.y, TRUE);

  ShowWindow (hMainWnd, iCmdShow) ;
  UpdateWindow (hMainWnd) ;
  
  while (GetMessage (&msg, NULL, 0, 0)) {
       TranslateMessage (&msg) ;
       DispatchMessage (&msg) ;
  }
  GdiplusShutdown(gdiplusToken);
  return msg.wParam ;
}
