#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define FNL_IMPL
#include "FastNoiseLite.h"

#define FLOW_FIELD_WIDTH 120
#define FLOW_FIELD_HEIGHT 120
#define N_STEPS 30
#define N_CURVES 1500
#define STEP_LENGTH 0.01 * FLOW_FIELD_WIDTH
#define D_SEP 0.8
#define DENSITY_GRID_WIDTH ((int) (FLOW_FIELD_WIDTH / D_SEP))

/* Simple struct to store the coordinates of a start point for a curve */
struct StartPoint {
	double x;
	double y;
} typedef StartPoint;

/* Struct to store all information about a curve that is being draw to the flow field */
struct Curve {
	int id;
	double* x;
	double* y;
} typedef Curve;

/* The density grid is a grid of density cells. Each cell can contain multiple points (x and y coordinates) */
struct DensityCell {
	double* x;
	double* y;
	int space_used;
	int capacity;
} typedef DensityCell;




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


/* generate a random floating point number from min to max */
double rand_from (double min, double max) {
    double range = (max - min); 
    double div = RAND_MAX / range;
    return min + (rand() / div);
}


void insert_coord_in_density_grid (double x,
				   double y,
				   double d_sep,
				   DensityCell density_grid[DENSITY_GRID_WIDTH][DENSITY_GRID_WIDTH]) {
	int density_col = get_density_col(x, d_sep);
	int density_row = get_density_row(y, d_sep);
	if (off_boundaries(density_col, density_row, DENSITY_GRID_WIDTH)) {
		return;
	}

	int space_used = density_grid[density_col][density_row].space_used;
	int capacity = density_grid[density_col][density_row].capacity;

	if ((space_used + 1) < capacity) {
		density_grid[density_col][density_row].x[space_used] = x;
		density_grid[density_col][density_row].y[space_used] = y;
		density_grid[density_col][density_row].space_used = space_used + 1;
	} else {
		printf("[ERROR]: Attempt to add coordinate in density cell that is out of capacity!\n");
	}
}


int is_valid_next_step (double x, double y,
		     double d_sep,
		     int density_grid_width,
		     DensityCell density_grid[DENSITY_GRID_WIDTH][DENSITY_GRID_WIDTH]) {
	int density_col = get_density_col(x, d_sep);
	int density_row = get_density_row(y, d_sep);
	if (off_boundaries(density_col, density_row, DENSITY_GRID_WIDTH)) {
		return 0;
	}
   
	int start_row = (density_row - 1) > 0 ? density_row - 1 : 0;
	int end_row = (density_row + 1) < density_grid_width ? density_row + 1 : density_row; 
	int start_col = (density_col - 1) > 0 ? density_col - 1 : 0;
	int end_col = (density_col + 1) < density_grid_width ? density_col + 1 : density_col;
 
	for (int c = start_col; c <= end_col; c++) {
		for (int r = start_row; r <= end_row; r++) {
			int n_elements = density_grid[c][r].space_used;
			if (n_elements == 0) {
				continue;
			}

			for (int i = 0; i < n_elements; i++) {
				double x2 = density_grid[c][r].x[i];
				double y2 = density_grid[c][r].y[i];
				double dist = distance(x, y, x2, y2);
				if (dist <= d_sep) {
					return 0;
				}
			}
		}
	}
  
	return 1;
}





int main() {
	double flow_field[120][120];
	// Create and configure noise state
	fnl_state noise = fnlCreateState();
	noise.seed = 50;
	noise.noise_type = FNL_NOISE_PERLIN;
	int index = 0;
	for (int y = 0; y < FLOW_FIELD_HEIGHT; y++) {
	    for (int x = 0; x < FLOW_FIELD_WIDTH; x++) {
			flow_field[x][y] = fnlGetNoise2D(&noise, x, y) * 2 * M_PI;
	    }
	}

	StartPoint* start_points = malloc(N_CURVES * sizeof(StartPoint));
	for (int i = 0; i < N_CURVES; i++) {
		srand(i + 1);
		start_points[i].x = rand_from(5, FLOW_FIELD_WIDTH - 5); 
		start_points[i].y = rand_from(5, FLOW_FIELD_WIDTH - 5);
	}

	Curve* curves = malloc(N_CURVES * sizeof(Curve));
	for (int i = 0; i < N_CURVES; i++) {
		curves[i].x = malloc(N_STEPS * sizeof(double));
		curves[i].y = malloc(N_STEPS * sizeof(double));
	}

	DensityCell density_grid[DENSITY_GRID_WIDTH][DENSITY_GRID_WIDTH];
	int density_capacity = 3 * 14000;
	for (int y = 0; y < DENSITY_GRID_WIDTH; y++) {
		for (int x = 0; x < DENSITY_GRID_WIDTH; x++) {
			density_grid[x][y].space_used = 0;
			density_grid[x][y].capacity = density_capacity;
			density_grid[x][y].x = malloc(density_capacity * sizeof(double));
			density_grid[x][y].y = malloc(density_capacity * sizeof(double));
		}
	}

	for (int curve_id = 0; curve_id < N_CURVES; curve_id++) {
		double x = start_points[curve_id].x;
		double y = start_points[curve_id].y;
		curves[curve_id].id = curve_id;

		for (int i = 0; i < N_STEPS; i++) {
			int ff_column_index = (int) floor(x);
			int ff_row_index = (int) floor(y);

			if (off_boundaries(ff_column_index, ff_row_index, FLOW_FIELD_WIDTH)) {
				break;
			}

			double angle = flow_field[ff_row_index][ff_column_index];
			double x_step = STEP_LENGTH * cos(angle);
			double y_step = STEP_LENGTH * sin(angle);
			x = x + x_step;
			y = y + y_step;


			int valid = is_valid_next_step(
				x, y,
				D_SEP,
				DENSITY_GRID_WIDTH,
				density_grid
			);

			if (!valid) {
				// This next step is not valid, stop drawing current curve
				// and jump to start drawing next curve.
				break;
			}

			curves[curve_id].x[i] = x;
			curves[curve_id].y[i] = y;
		}

		// After we finish calculating the coordinates of a curve,
		// we add the coordinates of this curve to the density grid.
		for (int i = 0; i < N_STEPS; i++) {
			double x = curves[curve_id].x[i];
			double y = curves[curve_id].y[i];
			insert_coord_in_density_grid(x, y, D_SEP, density_grid);
		}
	}

	// Free data
	for (int i = 0; i < N_CURVES; i++) {
		free(curves[i].x);
		free(curves[i].y);
	}

	for (int y = 0; y < DENSITY_GRID_WIDTH; y++) {
		for (int x = 0; x < DENSITY_GRID_WIDTH; x++) {
			free(density_grid[x][y].x);
			free(density_grid[x][y].y);
		}
	}

	free(start_points);
	free(curves);
	return 1;
}
