#include <stdlib.h>
#include <GL/glut.h>
#include <gl/gl.h>
#include <stdio.h>
#include <Windows.h>
#include <list>
#include <time.h>
#include <iostream>
#include <sstream>

using namespace std;

#ifndef COLOUR_H
#define COLOUR_H

class Colour
{
public:
	float r;
	float g;
	float b;
	float a;

	Colour();
	Colour(float r, float g, float b, float a);

	static Colour Red();
	static Colour Green();
	static Colour Blue();
	string ToString();
};
#endif