/*------MOTIF / CLASS VARIABLES---*/
// { {pitch <diatonic reference>, start position, duration, velocity, timbre A, timbre B} }
//simple form 1
float[][] simpleforms_1 =
{{ 0, 0.00, .375, 127, 0, 0},
{ 2, .375, .375, 127, 0, 0},
{-2, .750, .250, 127, 0, 0}};

Table simpleforms_table1;

float[][] simpleforms_2 =
{{ 0, 0.00, .375, 127, 0, 0},
{1, .375, .375, 127, 0, 0},
{2, .750, .250, 127, 0, 0}};

Table simpleforms_table2;

float[][] arch1_mm =
{{ 0, 0.00, .25, 127, 0, 0},
{ 4, 1/4.0, .25, 127, 0, 0},
{ 2, 2/4.0, .25, 127, 0, 0},
{ 7, 3/4.0, .25, 127, 0, 0}};

Table arch1_mm_table;

float[][] even_ascent_mm =
{{ 0, 0.00, .25, 127, 0, 0},
{ 1, 1/4.0, .25, 127, 0, 0},
{ 2, 2/4.0, .25, 127, 0, 0},
{ 3, 3/4.0, .25, 127, 0, 0},
{ 4, 4/4.0, .25, 127, 0, 0},
{ 5, 5/4.0, .25, 127, 0, 0},
{ 6, 6/4.0, .25, 127, 0, 0},
{ 7, 7/4.0, .25, 127, 0, 0}};

Table even_ascent_mm_table;

void loadMetamotifs(){
      simpleforms_table1 = loadTable("simpleforms_1.csv", "header");
      simpleforms_table2 = loadTable("simpleforms_2.csv", "header");
      arch1_mm_table = loadTable("arch1_mm.csv", "header");
      even_ascent_mm_table = loadTable("even_ascent_mm.csv", "header");
}
