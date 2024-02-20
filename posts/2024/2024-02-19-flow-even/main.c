#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define FNL_IMPL
#include "FastNoiseLite.h"


void build_flow_field (double* noiseData, int n) {
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


/* generate a random floating point number from min to max */
double rand_from(double min, double max) {
    double range = (max - min); 
    double div = RAND_MAX / range;
    return min + (rand() / div);
}




struct Curve {
	int id;
	double* x;
	double* y;
} typedef Curve;

void print_curve_coords(Curve* curve, int n_steps) {
	for (int i = 0; i < n_steps; i++) {
		double x = curve->x[i];
		double y = curve->y[i];
		printf("x: %f, y: %f\n", x, y);
	}
}

struct StartPoint {
	double x;
	double y;
} typedef StartPoint;

struct DensityCell {
	double* x;
	double* y;
	int space_used;
	int capacity;
} typedef DensityCell;

void insert_coord_in_density_grid (double x, double y, double d_sep, DensityCell* density_grid) {
	int density_col = get_density_col(x, d_sep);
	int density_row = get_density_row(y, d_sep);
	
	int density_grid_index = density_row * density_col;
	int space_used = density_grid[density_grid_index].space_used;
	int capacity = density_grid[density_grid_index].capacity;
	
	if ((space_used + 1) < capacity) {
		density_grid[density_grid_index].x[space_used] = x;
		density_grid[density_grid_index].y[space_used] = y;
		density_grid[density_grid_index].space_used = space_used + 1;
	} else {
		printf("[ERROR]: Attempt to add coordinate in density cell that is out of capacity!\n");
	}
}


int valid_seedpoint (double x, double y,
		     int field_width,
		     double d_sep,
		     int density_grid_width,
		     DensityCell* density_grid) {

	int density_col = get_density_col(x, d_sep);
	int density_row = get_density_row(y, d_sep);
   
	int start_row = (density_row - 1) > 0 ? (density_row - 1) : 0;
	int end_row = (density_row + 1) < field_width ? (density_row + 1) : field_width; 
	int start_col = (density_col - 1) > 0 ? (density_col - 1) : 0;
	int end_col = (density_col + 1) < field_width ? (density_col + 1) : field_width; 
 
	for (int c = start_col; c <= end_col; c++) {
		for (int r = start_row; r <= end_row; r++) {
			int density_grid_index = r * c;
			if (density_grid_index <= 0 ||
			    density_grid_index > (density_grid_width * density_grid_width)) {
				printf("[ERROR]: Attempt to access a cell that is out of boundaries of the density grid! Index: %i\n", density_grid_index);
			}

			int n_elements = density_grid[density_grid_index].space_used;
			if (n_elements == 0) {
				continue;
			}

			for (int i = 0; i < n_elements; i++) {
				double x2 = density_grid[density_grid_index].x[i];
				double y2 = density_grid[density_grid_index].y[i];
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
	int n = 120;
	int field_width = n;
	int field_height = n;
	int n_curves = 500;
	int n_steps = 30;
	double d_sep = 0.5;
	double step_length = 0.01 * field_width;
	char* filename = "curves.csv";
	printf("[INFO]: Setting up a flow field with dimensions %ix%i.\n", field_width, field_height);
	printf("[INFO]: Number of curves that will be calculated is %i.\n", n_curves);
	printf("[INFO]: Number of steps taken for each curve is %i.\n", n_steps);
	printf("[INFO]: Length (i.e. distance) of each step taken is %f.\n", step_length);
	printf("[INFO]: The distance factor between each curve is configured to %f.\n", d_sep);


	double* angles = malloc(n * n * sizeof(double));
	build_flow_field(angles, n);

	printf("[INFO]: Generating %i random starting points for %i curves.\n", n_curves, n_curves);
	StartPoint* start_points = malloc(n_curves * sizeof(StartPoint));
	for(int i = 0; i < n_curves; i++){
		srand(i + 1);
		start_points[i].x = rand_from(20, field_width - 30); 
		start_points[i].y = rand_from(20, field_width - 30);
		// printf("x: %f | y: %f\n", start_points[i].x, start_points[i].y);
	}

	printf("[INFO]: Allocating space to store the coordinates of %i curves.\n", n_curves);
	Curve* curves = malloc(n_curves * sizeof(Curve));
	for (int i = 0; i < n_curves; i++) {
		curves[i].x = malloc(n_steps * sizeof(double));
		curves[i].y = malloc(n_steps * sizeof(double));
	}

	int density_grid_width = ((int) (field_width / d_sep));
	printf("[INFO]: Setting up a density grid with dimensions %ix%i.\n", density_grid_width, density_grid_width);
	DensityCell* density_grid = malloc(density_grid_width * density_grid_width * sizeof(DensityCell));
	int density_capacity = 14000;
	for (int i = 0; i < (density_grid_width * density_grid_width); i++) {
		density_grid[i].space_used = 0;
		density_grid[i].capacity = density_capacity;
		density_grid[i].x = malloc(density_capacity * sizeof(double));
		density_grid[i].y = malloc(density_capacity * sizeof(double));
	}




	printf("[INFO]: Starting to calculate the curves.\n");
	for (int curve_id = 0; curve_id < n_curves; curve_id++) {
		double x = start_points[curve_id].x;
		double y = start_points[curve_id].y;
		curves[curve_id].id = curve_id;
  
		for (int i = 0; i < n_steps; i++) {
			int ff_column_index = (int) x;
			int ff_row_index = (int) y;

			if (off_boundaries(ff_column_index, ff_row_index, field_width)) {
				break;
			}

			double angle = angles[ff_row_index * ff_column_index];
			double x_step = step_length * cos(angle);
			double y_step = step_length * sin(angle);
			x = x + x_step;
			y = y + y_step;

			
			int valid = valid_seedpoint(
				x, y,
				field_width,
				d_sep,
				density_grid_width,
				density_grid
			);

			if (!valid) {
				// Current seedpoint is not valid, stop drawing current curve
				// and jump to start drawing next curve.
				break;
			}

			curves[curve_id].x[i] = x;
			curves[curve_id].y[i] = y;
		}

		// After we finish calculating the coordinates of a curve,
		// we add the coordinates of this curve to the density grid.
		for (int i = 0; i < n_steps; i++) {
			double x = curves[curve_id].x[i];
			double y = curves[curve_id].y[i];
			insert_coord_in_density_grid(x, y, d_sep, density_grid);
		}
	}
	printf("[INFO]: Finished calculating curves!\n");
	printf("[INFO]: Saving curves data into CSV %s\n", filename);
	FILE* f = fopen(filename, "w");
	fprintf(f, "curve_id;x;y\n");
	for (int curve_id = 0; curve_id < n_curves; curve_id++) {
		for (int i = 0; i < n_steps; i++) {
			fprintf(
				f,
				"%d;%.8f;%.8f\n",
				curves[curve_id].id,
				curves[curve_id].x[i],
				curves[curve_id].y[i]
			);
		}
	};
	fclose(f);


	// Free data 
	printf("[INFO]: Freeing data before exit...\n");
	for (int i = 0; i < n_curves; i++) {
		free(curves[i].x);
		free(curves[i].y);
	}

	for (int i = 0; i < (density_grid_width * density_grid_width); i++) {
		free(density_grid[i].x);
		free(density_grid[i].y);
	}
	
	free(angles);
	free(start_points);
	free(density_grid);
	free(curves);

	return 1;
}


