#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <X11/Xatom.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>

#define BAR 46
#define DOCK_H 94
#define ICONS 6
static Display *d; static Window root, shell, focus=0; static int sw,sh,desk=0,hover=-1;
static unsigned long col(const char *s){Colormap m=DefaultColormap(d,DefaultScreen(d));XColor c;XParseColor(d,m,s,&c);XAllocColor(d,m,&c);return c.pixel;}
static void launch(const char *cmd){if(!fork()){setsid();execl("/bin/sh","sh","-c",cmd,(char*)0);_exit(127);}}
static void rounded(GC g,int x,int y,int w,int h,unsigned long c){XSetForeground(d,g,c);XFillRectangle(d,shell,g,x+12,y,w-24,h);XFillRectangle(d,shell,g,x,y+12,w,h-24);XFillArc(d,shell,g,x,y,24,24,90*64,90*64);XFillArc(d,shell,g,x+w-24,y,24,24,0,90*64);XFillArc(d,shell,g,x,y+h-24,24,24,180*64,90*64);XFillArc(d,shell,g,x+w-24,y+h-24,24,24,270*64,90*64);}
static void icon(GC g,int x,int y,int i,int size){const char *cs[]={"#8bf7ff","#ff4fd8","#a77bff","#4de3a8","#ffc857","#ff7799"};XSetForeground(d,g,col(cs[i]));XFillArc(d,shell,g,x-size/2,y-size/2,size,size,0,360*64);XSetForeground(d,g,col("#07101d"));const char *t[]={"N",">_","F","W","S","+"};XDrawString(d,shell,g,x-5,y+6,t[i],1);}
static void redraw(void){XClearWindow(d,shell);GC g=XCreateGC(d,shell,0,0);rounded(g,0,0,sw,BAR,col("#11182c"));XSetForeground(d,g,col("#8bf7ff"));XDrawString(d,shell,g,22,30,"NGOS",4);XSetForeground(d,g,col("#aeb9d8"));char info[96];snprintf(info,sizeof info,"WORKSPACE %d/4   |   NEURAL DESKTOP   |   INTEL x86_64",desk+1);XDrawString(d,shell,g,sw/2-185,30,info,strlen(info));XSetForeground(d,g,col("#61709b"));XDrawString(d,shell,g,sw-170,30,"09:30   ONLINE",14);
 rounded(g,sw/2-250,sh-DOCK_H,500,70,col("#18223b"));XSetForeground(d,g,col("#314264"));XDrawRectangle(d,shell,g,sw/2-250,sh-DOCK_H,499,69);int center=sw/2;for(int i=0;i<ICONS;i++){int dx=(i-ICONS/2)*70;int dist=abs(i-(hover<0?ICONS/2:hover));int sz=dist==0?58:(dist==1?49:42);int yy=sh-DOCK_H+35-(dist==0?10:0);icon(g,center+dx,yy,i,sz);}XSetForeground(d,g,col("#7584a8"));XDrawString(d,shell,g,sw/2-228,sh-DOCK_H+62,"LAUNCHER     TERMINAL     FILES     WEB     SYSTEM",49);XSetForeground(d,g,col("#8bf7ff"));XFillRectangle(d,shell,g,sw/2-30,sh-15,60,3);XFreeGC(d,g);}
static void key(XKeyEvent *e){KeySym k=XLookupKeysym(e,0);unsigned m=e->state&Mod4Mask;if(m&&k==XK_Return)launch("xterm");else if(m&&k==XK_m&&focus)XUnmapWindow(d,focus);else if(m&&(k>=XK_1&&k<=XK_4)){desk=k-XK_1;redraw();}else if(m&&k==XK_space)launch("xterm -e sh -c 'printf \"NGOS LAUNCHER\\n\\n1 Terminal\\n2 Files\\n3 Browser\\n\"; read'");else if(m&&k==XK_q&&focus)XKillClient(d,focus);}
static void map_client(Window c){XWindowAttributes a;XGetWindowAttributes(d,c,&a);if(a.override_redirect)return;XSetWindowBorderWidth(d,c,3);XSetWindowBorder(d,c,col("#8bf7ff"));XMoveWindow(d,c,120,110);XMapRaised(d,c);XSetInputFocus(d,c,RevertToPointerRoot,CurrentTime);focus=c;}
int main(void){d=XOpenDisplay(0);if(!d)return 1;int s=DefaultScreen(d);root=RootWindow(d,s);sw=DisplayWidth(d,s);sh=DisplayHeight(d,s);XSelectInput(d,root,SubstructureRedirectMask|SubstructureNotifyMask|KeyPressMask);KeySym keys[]={XK_Return,XK_m,XK_space,XK_q};for(unsigned i=0;i<4;i++)XGrabKey(d,XKeysymToKeycode(d,keys[i]),Mod4Mask,root,1,GrabModeAsync,GrabModeAsync);for(int i=0;i<4;i++)XGrabKey(d,XKeysymToKeycode(d,XK_1+i),Mod4Mask,root,1,GrabModeAsync,GrabModeAsync);XSetWindowAttributes wa;wa.override_redirect=True;wa.background_pixel=col("#060914");shell=XCreateWindow(d,root,0,0,sw,sh,0,CopyFromParent,InputOutput,CopyFromParent,CWOverrideRedirect|CWBackPixel,&wa);XSelectInput(d,shell,ExposureMask|KeyPressMask|PointerMotionMask);XMapWindow(d,shell);XLowerWindow(d,shell);XSetInputFocus(d,shell,RevertToPointerRoot,CurrentTime);redraw();for(;;){XEvent e;XNextEvent(d,&e);if(e.type==Expose)redraw();else if(e.type==KeyPress)key(&e.xkey);else if(e.type==MotionNotify){int left=sw/2-210;int n=(e.xmotion.x-left+35)/70;int nh=(n>=0&&n<ICONS)?n:-1;if(nh!=hover){hover=nh;redraw();}}else if(e.type==MapRequest)map_client(e.xmaprequest.window);else if(e.type==DestroyNotify&&focus==e.xdestroywindow.window)focus=0;}}
