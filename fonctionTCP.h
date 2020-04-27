#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>


int socketServeur(ushort nPort);
int socketClient(char* nomMachine , ushort nPort);