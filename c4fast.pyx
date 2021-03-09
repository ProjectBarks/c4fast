# distutils: language = c++
# cython: c_string_type=unicode, c_string_encoding=utf8

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from 'Position.hpp' namespace 'GameSolver::Connect4':
    int P_WIDTH 'GameSolver::Connect4::Position::WIDTH'

    int HEIGHT 'GameSolver::Connect4::Position::HEIGHT'

    cdef cppclass _Position 'GameSolver::Connect4::Position':
        _Position()

        bint canWinNext()
        int nbMoves()
        bint isWinningMove(int col)
        bint canPlay(int col)
        unsigned int play(const string& seq)
        void playCol(int col)

cdef class Position:
    cdef _Position position

    def __cinit__(self):
        self.position = _Position()

    def can_win_next(self) -> bool:
        return self.position.canWinNext()

    def is_winning_move(self, col) -> bool:
        return self.position.isWinningMove(col)

    def nb_moves(self) -> int:
        return self.position.nbMoves()

    def can_play(self, int col) -> bool:
        return self.position.canPlay(col)

    def play(self, str seq) -> int:
        for i, s in enumerate(seq):
            col = ord(s) - ord('1')
            print(col, P_WIDTH, i)
            if col < 0 or col >= P_WIDTH or not self.can_play(col) or self.is_winning_move(col):
                return i # Invalid Move
            self.play_col(col)
        return len(seq)


    def play_col(self, int col) -> void:
        return self.position.playCol(col)

cdef extern from 'Solver.cpp' namespace 'GameSolver::Connect4':
    pass

cdef extern from 'Solver.hpp' namespace 'GameSolver::Connect4':
    cdef cppclass _Solver 'GameSolver::Connect4::Solver':
        _Solver()

        int loadBook(string book_file)
        int solve(const _Position& p, bint weak)
        void reset()
        vector[int] analyze(const _Position& p, bint weak)
        unsigned long long getNodeCount()

class BookException(Exception):
    def __init__(self, msg=None, *args, **kwargs):
        merged_msg = 'Unable to load opening book'
        if msg != None:
            merged_msg = f'{merged_msg}: {msg}'
        super(Exception).__init__(self, msg, *args, **kwargs)

cdef class Solver:
    cdef _Solver* solver

    def __cinit__(self):
        self.solver = new _Solver()

    def __dealloc__(self):
        del self.solver

    def load_book(self, str book_file) -> void:
        result = self.solver.loadBook(book_file)
        if result != 0:
            if result == -1 or result == -8 or result == -9: raise BookException()
            elif result == -2: raise BookException('invalid width')
            elif result == -3: raise BookException('invalid height')
            elif result == -4: raise BookException('invalid depth')
            elif result == -5: raise BookException('invalid internal key size')
            elif result == -6: raise BookException('invalid value size')
            elif result == -7: raise BookException('invalid log2(size)')
            else: raise BookException('Unknown Exception')


    def solve(self, Position position, bint weak=False) -> int:
        return self.solver.solve(position.position, weak)

    def analyze(self, Position position, bint weak=False) -> [int]:
        return self.solver.analyze(position.position, weak)

    def reset(self) -> void:
        self.solver.reset()

    def get_node_count(self) -> int:
        return self.solver.getNodeCount()