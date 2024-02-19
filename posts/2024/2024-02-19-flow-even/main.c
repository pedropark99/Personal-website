#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define FNL_IMPL
#include "FastNoiseLite.h"


void build_angle_grid (double* noiseData, int n) {
	// Create and configure noise state
	fnl_state noise = fnlCreateState();
	noise.seed = 50;
	noise.noise_type = FNL_NOISE_PERLIN;
	int index = 0;
	for (int y = 0; y < n; y++)
	{
	    for (int x = 0; x < n; x++) 
	    {
		noiseData[index++] = fnlGetNoise2D(&noise, x, y);
	    }
	}
}

int get_density_col (double x, double d_sep) {
	double c = (x / d_sep) + 1;
	return (int) c;
}

int get_density_row (double y, double d_sep) {
	double r = (y / d_sep) + 1;
	return (int) r;
}

double distance (double x1, double y1, double x2, double y2) {
	double s1 = pow(x2 - x1, 2.0);
	double s2 = pow(y2 - y1, 2.0);
	return sqrt(s1 + s2);
}

int off_boundaries (double x, double y, int limit) {
	return (
	    x <= 0 ||
	    y <= 0 ||
	    x >= limit ||
	    y >= limit
	);
}



int valid_seedpoint (double x, double y, int curve_id, double d_sep) {
	int density_col = get_density_col(x, d_sep);
	int density_row = get_density_row(y, d_sep);
	  
	int sc = (density_col - 1);
	int ec = (density_col + 1);
	int sr = (density_row - 1);
	int er = (density_row + 1);
	  
	int result = 1;
	return result;
}



int main() {
	int n = 120;
	double* noiseData = malloc(n * n * sizeof(double));
	build_angle_grid(noiseData, n);


	int grid_width = n;
	int grid_height = n;
	int n_curves = 20;
	int n_steps = 30;
	double d_sep = 0.4;
	double step_length = 0.01 * grid_width;

	printf("x: %f\n", noiseData[15]);
	// Free data later
	free(noiseData);

	return 1;
}
