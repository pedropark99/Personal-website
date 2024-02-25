#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define FNL_IMPL
#include "FastNoiseLite.h"

#define FLOW_FIELD_WIDTH 120
#define FLOW_FIELD_HEIGHT 120
#define N_STEPS 30
#define MIN_STEPS_ALLOWED 5
#define N_CURVES 1500
#define STEP_LENGTH 0.01 * FLOW_FIELD_WIDTH
#define D_SEP 1
#define D_TEST 1
#define DENSITY_GRID_WIDTH ((int) (FLOW_FIELD_WIDTH / D_SEP))

struct Point {
	double x;
	double y;
} typedef Point;

/* Struct to store all information about a curve that is being draw to the flow field */
struct Curve {
	int curve_id;
	double x[N_STEPS];
	double y[N_STEPS];
	// If x and y coordinates are from a step that was taken from left to right (1)
	// or a step from right to left (0).
	int direction[N_STEPS];
	// The id of the step
	int step_id[N_STEPS];
	int steps_taken;
} typedef Curve;

/* The density grid is a grid of density cells. Each cell can contain multiple points (x and y coordinates) */
struct DensityCell {
	double* x;
	double* y;
	int space_used;
	int capacity;
} typedef DensityCell;


struct SeedPointsQueue {
	Point* points;
	int space_used;
	int capacity;
} typedef SeedPointsQueue;




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
			double d_test,
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

	// Subtracting a very small amount from D_TEST, just to account for the lost of float precision
	// that happens during the calculations below, specially in the distance calc
	d_test = d_test - (0.01 * D_SEP);
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
				if (dist <= d_test) {
					return 0;
				}
			}
		}
	}

	return 1;
}




Curve draw_curve(double x_start, double y_start, int curve_id,
		 double flow_field[FLOW_FIELD_WIDTH][FLOW_FIELD_HEIGHT],
		 DensityCell density_grid[DENSITY_GRID_WIDTH][DENSITY_GRID_WIDTH]) {

	Curve curve;
	curve.curve_id = curve_id;
	curve.steps_taken = 0;
	for (int i = 0; i < N_STEPS; i++) {
		curve.x[i] = 0;
		curve.y[i] = 0;
		curve.direction[i] = 0;
		curve.step_id[i] = 0;
	}

	double x = x_start;
	double y = y_start;
	int direction = 0;
	curve.x[0] = x_start;
	curve.y[0] = y_start;
	int step_id = 1;
	int i = 1;
	// Draw curve from right to left
	while (i < (N_STEPS / 2)) {
		int ff_column_index = (int) floor(x);
		int ff_row_index = (int) floor(y);

		if (off_boundaries(ff_column_index, ff_row_index, FLOW_FIELD_WIDTH)) {
			break;
		}

		double angle = flow_field[ff_row_index][ff_column_index];
		double x_step = STEP_LENGTH * cos(angle);
		double y_step = STEP_LENGTH * sin(angle);
		x = x - x_step;
		y = y - y_step;

		int valid = is_valid_next_step(
			x, y,
			D_SEP,
			D_TEST,
			DENSITY_GRID_WIDTH,
			density_grid
		);

		if (!valid) break;

		curve.x[i] = x;
		curve.y[i] = y;
		curve.step_id[i] = step_id;
		step_id++;
		curve.steps_taken++;
		i++;
	}


	x = x_start;
	y = y_start;
	// Draw curve from left to right
	while (i < N_STEPS) {
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
			D_TEST,
			DENSITY_GRID_WIDTH,
			density_grid
		);

		if (!valid) break;

		curve.x[i] = x;
		curve.y[i] = y;
		curve.direction[i] = 1;
		curve.step_id[i] = step_id;
		step_id++;
		curve.steps_taken++;
		i++;
	}

	return curve;
}


SeedPointsQueue collect_seedpoints (Curve curve) {
	int steps_taken = curve.steps_taken;
	SeedPointsQueue queue;
	queue.space_used = 0;
	if (steps_taken == 0) {
		queue.capacity = 0;
		return queue;
	}

	queue.points = malloc(steps_taken * 2 * sizeof(Point));
	queue.capacity = steps_taken * 2;
	int candidate_point_index = 0;
	for (int i = 0; i < steps_taken - 1; i++) {
		double x = curve.x[i];
		double y = curve.y[i];
			
		int ff_column_index = (int) floor(x);
		int ff_row_index = (int) floor(y);
		double angle = atan2(curve.y[i + 1] - y, curve.x[i + 1] - x);

		double angle_left = angle + (M_PI / 2);
		double angle_right = angle - (M_PI / 2);

		Point left_point = {
			x + (D_SEP * cos(angle_left)),
			y + (D_SEP * sin(angle_left))
		};
		Point right_point = {
			x + (D_SEP * cos(angle_right)),
			y + (D_SEP * sin(angle_right))
		};

		queue.points[candidate_point_index] = left_point;
		candidate_point_index++;
		queue.space_used++;
		queue.points[candidate_point_index] = right_point;
		candidate_point_index++;
		queue.space_used++;
	}

	return queue;
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


	Curve curves[N_CURVES];
	double x = 45.0;
	double y = 24.0;
	int curve_array_index = 0;
	int curve_id = 0;
	curves[curve_array_index] = draw_curve(x, y, curve_id, flow_field, density_grid);
	int steps_taken = curves[curve_array_index].steps_taken;
	for (int i = 0; i < steps_taken + 1; i++) {
		double x = curves[curve_array_index].x[i];
		double y = curves[curve_array_index].y[i];
		insert_coord_in_density_grid(x, y, D_SEP, density_grid);
	}
	curve_array_index++;



	while (curve_id < N_CURVES && curve_array_index < N_CURVES) {
		SeedPointsQueue queue;
		queue = collect_seedpoints(curves[curve_id]);
		for (int point_index = 0; point_index < queue.space_used; point_index++) {
			Point p = queue.points[point_index];
			// check if it is valid given the current state
			int valid = is_valid_next_step(
				p.x, p.y,
				D_SEP,
				D_SEP,
				DENSITY_GRID_WIDTH,
				density_grid
			);

			if (valid) {
				// if it is, draw the curve from it
				Curve curve = draw_curve(
					p.x, p.y,
					curve_array_index,
					flow_field,
					density_grid
				);
				if (curve.steps_taken < MIN_STEPS_ALLOWED) {
					continue;
				}

				curves[curve_array_index] = curve;
				// insert this new curve into the density grid
				int steps_taken = curves[curve_array_index].steps_taken;
				for (int i = 0; i < steps_taken + 1; i++) {
					double x = curves[curve_array_index].x[i];
					double y = curves[curve_array_index].y[i];
					insert_coord_in_density_grid(x, y, D_SEP, density_grid);
				}
				curve_array_index++;
			}
		}

		curve_id++;
	}

	
	char* filename = "even_curves.csv";
	printf("[INFO]: Finished calculating curves!\n");
	printf("[INFO]: Saving curves data into CSV %s\n", filename);
	FILE* f = fopen(filename, "w");
	fprintf(f, "curve_id;x;y;step_id;direction\n");
	/*
	for (int pi = 0; pi < (N_STEPS * 2); pi++) {
		fprintf(
				f,
				"%d;%.8f;%.8f\n",
				pi,
				candidate_points[pi].x,
				candidate_points[pi].y
		);
	};*/
	for (int curve_id = 0; curve_id < N_CURVES; curve_id++) {
		for (int i = 0; i < N_STEPS; i++) {
			fprintf(
				f,
				"%d;%.8f;%.8f;%d;%d\n",
				curves[curve_id].curve_id,
				curves[curve_id].x[i],
				curves[curve_id].y[i],
				curves[curve_id].step_id[i],
				curves[curve_id].direction[i]
			);
		}
	};
	fclose(f);

	

	// Free data
	for (int y = 0; y < DENSITY_GRID_WIDTH; y++) {
		for (int x = 0; x < DENSITY_GRID_WIDTH; x++) {
			free(density_grid[x][y].x);
			free(density_grid[x][y].y);
		}
	}

	return 1;
}
