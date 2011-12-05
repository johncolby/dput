function test_suite = test_dput
%TEST_DPUT - xUnit tests for dput
%See also: DPUT
%          http://www.mathworks.com/matlabcentral/fileexchange/22846

initTestSuite;

function test_double
[x x_orig] = deal(1);
eval(dput(x))
assertEqual(x, x_orig)

function test_double_2d
[x x_orig] = deal(magic(5));
eval(dput(x))
assertEqual(x, x_orig)

function test_double_3d
[x x_orig] = deal(randi([0 1], [3 3 3]));
eval(dput(x))
assertEqual(x, x_orig)

function test_double_3d_decimal
[x x_orig] = deal(randn([3 3 3]));
eval(dput(x))
assertVectorsAlmostEqual(x, x_orig, 'absolute', 1e-5)

function test_double_3d_decimal_precise
[x x_orig] = deal(randn([3 3 3]));
eval(dput(x, 'precision', 15))
assertVectorsAlmostEqual(x, x_orig, 'absolute', 1e-14)

function test_str
[x x_orig] = deal(['line1'; 'line2']);
eval(dput(x))
assertEqual(x, x_orig)

function test_struct
[x x_orig] = deal(struct('index', num2cell(1:3), 'color', {'red', 'blue',...
                         'green'}, 'misc', {'string' 4 num2cell(magic(3))}));
eval(dput(x))
assertEqual(x, x_orig)

function test_cell
[x x_orig] = deal({1:3, 'test'; [], 1});
eval(dput(x))
assertEqual(x, x_orig)

function test_logical
[x x_orig] = deal(logical(randi([0 1], 3)));
eval(dput(x))
assertEqual(x, x_orig)

function test_uint64
[x x_orig] = deal(intmax('uint64'));
eval(dput(x))
assertEqual(x, x_orig)

function test_cell_str_struct_logical_uint64
[x x_orig] = deal({1:3, 'test';
                   [], logical(randi([0 1], 3));
                   intmax('uint64'), struct('index', num2cell(1:3), 'color', {'red', 'blue',...
                                            'green'}, 'misc', {'string' 4 num2cell(magic(3))})});
eval(dput(x))
assertEqual(x, x_orig)

function test_complex
[x x_orig] = deal(randn + randn*1i);
eval(dput(x))
assertVectorsAlmostEqual(x, x_orig, 'absolute', 1e-5)
