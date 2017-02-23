#include "block.h"

Block :: Block() {}

Block :: Block (Vector3 position, Colour colour, int scale)
{
	this->transform = Transform(position);
	this->colour = colour;
	this->scale = scale;
}

void Block :: drawCube ()
{
	float m_diff[] = { 0.2f, 0.2f, 0.2f, 1.0f };
	float m_spec[] = { 0.6f, 0.6f, 0.6f, 1.0f };
	float shiny = 30.0f;

	//cout << colour.ToString() << endl;
	float c[] = { colour.r, colour.g, colour.b, colour.a };
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, c);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, m_diff);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, m_spec);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, shiny);

	glPushMatrix();
	glTranslatef(transform.position.x, transform.position.y, transform.position.z);
	//glScalef(scale_,scale_,scale_);

	glBegin(GL_QUADS);

	//bottom
	glNormal3f(0,-1,0);
	glVertex3f(0,0,0);
	glVertex3f(1,0,0);
	glVertex3f(1,0,1);
	glVertex3f(0,0,1);
	//right side
	glNormal3f(-1,0,0);
	glVertex3f(0,0,1);
	glVertex3f(0,0,0);
	glVertex3f(0,1,0);
	glVertex3f(0,1,1);
	//back side
	glNormal3f(0,0,-1);
	glVertex3f(0,1,1);
	glVertex3f(1,1,1);
	glVertex3f(1,0,1);
	glVertex3f(0,0,1);
	//front side
	glNormal3f(0, 0, 1);
	glVertex3f(0,0,0);
	glVertex3f(1,0,0);
	glVertex3f(1,1,0);
	glVertex3f(0,1,0);
	//top
	glNormal3f(0,1,0);
	glVertex3f(0,1,0);
	glVertex3f(1,1,0);
	glVertex3f(1,1,1);
	glVertex3f(0,1,1);
	//left side
	glNormal3f(1, 0, 0);
	glVertex3f(1,0,0);
	glVertex3f(1,0,1);
	glVertex3f(1,1,1);
	glVertex3f(1,1,0);

	glEnd();
	glPopMatrix();

}