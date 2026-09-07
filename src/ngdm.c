#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/wait.h>
int main(void){ const char *user=getenv("USER"); if(!user) user="ngos"; fprintf(stderr,"NGDM: starting session for %s\n",user); for(;;){ pid_t p=fork(); if(p==0){ execl("/usr/bin/xinit","xinit","/usr/bin/ngos-session","--","-nolisten","tcp",(char*)0); _exit(127); } if(p<0) return 1; int st; waitpid(p,&st,0); sleep(1); } }
