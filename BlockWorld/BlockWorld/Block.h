#include <stdlib.h>
#include <GL/glut.h>
#include <gl/gl.h>
#include <stdio.h>
#include <Windows.h>
#include <list>
#include <time.h>
#include "Vector.h"
#include "Transform.h"
#include "Colour.h"

using namespace std;

#ifndef BLOCK_H
#define BLOCK_H

class Block
{
	public:
		Transform transform;
		Colour colour;
		float speed;
		int scale;

		Block();
		Block(Vector3 position, Colour colour, int scale);
		void drawCube();
};
#endif