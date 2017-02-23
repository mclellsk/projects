#include "Colour.h"

Colour::Colour() {}
Colour::Colour(float r, float g, float b, float a)
{
	this->r = r;
	this->g = g;
	this->b = b;
	this->a = a;
}

Colour Colour::Red()
{
	return Colour(1.0f, 0.0f, 0.0f, 1.0f);
}
Colour Colour::Green()
{
	return Colour(0.0f, 1.0f, 0.0f, 1.0f);
}
Colour Colour::Blue()
{
	return Colour(0.0f, 0.0f, 1.0f, 1.0f);
}

string Colour::ToString()
{
	std::ostringstream ss;
	ss << "r:";
	ss << r;
	ss << " g:";
	ss << g;
	ss << " b:";
	ss << b;
	return ss.str();
}

