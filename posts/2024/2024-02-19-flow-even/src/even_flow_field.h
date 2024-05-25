#pragma once

#include <stdlib.h>
#include <math.h>

/* Simple struct to store the coordinates of a start point for a curve */
struct StartPoint {
	double x;
	double y;
} typedef StartPoint;


/* Distance between two points */
double distance (double x1, double y1, double x2, double y2);

/* Check if coordinate is out of the boundaries of the flow field */
int off_boundaries (double x, double y, int limit);

/* generate a random floating point number from min to max */
double rand_from(double min, double max);


/* Struct to store all information about a curve that is being draw to the flow field */
struct Curve {
	int id;
	double* x;
	double* y;
} typedef Curve;

/* Print the coordinates that make a curve */
void print_curve_coords(Curve* curve, int n_steps);


/* The density grid is a grid of density cells. Each cell can contain multiple points (x and y coordinates) */
struct DensityCell {
	double* x;
	double* y;
	int space_used;
	int capacity;
} typedef DensityCell;

/* Get column index in the density grid that is mapped to the current x and y coordinates */
int get_density_col (double x, double d_sep);
/* Get row index in the density grid that is mapped to the current x and y coordinates */
int get_density_row (double y, double d_sep);


