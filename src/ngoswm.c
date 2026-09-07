#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <X11/Xatom.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>

#define BAR 42
#define DOCK 72
#define WS 4
static Display *d; static Window root, shell; static int sw, sh, desk=0; static Window focus=0;
static unsigned long col(const char *s){ Colormap m=DefaultColormap(d,DefaultScreen(d)); XColor c; XParseColor(d,m,s,&c); XAllocColor(d,m,&c); return c.pixel; }
static void launch(const char *cmd){ if(!fork()){ setsid(); execl("/bin/sh","sh","-c",cmd,(char*)0); _exit(127); } }
static void redraw(void){ XClearWindow(d,shell); GC g=XCreateGC(d,shell,0,0); XSetForeground(d,g,col("#111528")); XFillRectangle(d,shell,g,0,0,sw,BAR); XSetForeground(d,g,col("#8bf7ff")); XDrawString(d,shell,g,22,27,"NGOS",4); XSetForeground(d,g,col("#9ca7c7")); char info[80]; snprintf(info,sizeof info,"WORKSPACE %d/4   |   NEXT GENERATION OPERATING SYSTEM",desk+1); XDrawString(d,shell,g,sw/2-150,27,info,strlen(info)); XSetForeground(d,g,col("#0b0f1d")); XFillRectangle(d,shell,g,0,sh-DOCK,sw,DOCK); XSetForeground(d,g,col("#ff4fd8")); XFillRectangle(d,shell,g,sw/2-120,sh-DOCK+16,240,40); XSetForeground(d,g,col("#070a14")); XDrawString(d,shell,g,sw/2-92,sh-DOCK+41,"[+]  LAUNCH    TERMINAL    FILES",31); XFreeGC(d,g); }
static void key(XKeyEvent *e){ KeySym k=XLookupKeysym(e,0); unsigned m=e->state&Mod4Mask; if(m&&k==XK_Return) launch("xterm"); else if(m&&k==XK_m&&focus){ XUnmapWindow(d,focus); } else if(m&&(k>=XK_1&&k<=XK_4)){desk=k-XK_1; redraw();} else if(m&&k==XK_space){ launch("xterm -e sh -c 'printf \"NGOS LAUNCHER\\n\"; read'"); } else if(m&&k==XK_q&&focus) XKillClient(d,focus); }
int main(void){ d=XOpenDisplay(0); if(!d) return 1; int s=DefaultScreen(d); root=RootWindow(d,s); sw=DisplayWidth(d,s); sh=DisplayHeight(d,s); XSelectInput(d,root,SubstructureRedirectMask|SubstructureNotifyMask|KeyPressMask); XGrabKey(d,XKeysymToKeycode(d,XK_Return),Mod4Mask,root,1,GrabModeAsync,GrabModeAsync); XGrabKey(d,XKeysymToKeycode(d,XK_m),Mod4Mask,root,1,GrabModeAsync,GrabModeAsync); XGrabKey(d,XKeysymToKeycode(d,XK_space),Mod4Mask,root,1,GrabModeAsync,GrabModeAsync); for(int i=0;i<4;i++) XGrabKey(d,XKeysymToKeycode(d,XK_1+i),Mod4Mask,root,1,GrabModeAsync,GrabModeAsync); shell=XCreateSimpleWindow(d,root,0,0,sw,sh,0,col("#060914"),col("#060914")); XSelectInput(d,shell,ExposureMask|KeyPressMask); XMapWindow(d,shell); XSetInputFocus(d,shell,RevertToPointerRoot,CurrentTime); redraw(); for(;;){ XEvent e; XNextEvent(d,&e); if(e.type==Expose) redraw(); else if(e.type==KeyPress) key(&e.xkey); else if(e.type==MapRequest){ XMapWindow(d,e.xmaprequest.window); focus=e.xmaprequest.window; XSetInputFocus(d,focus,RevertToPointerRoot,CurrentTime); } else if(e.type==DestroyNotify&&focus==e.xdestroywindow.window) focus=0; } }
