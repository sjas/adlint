Feature: W0649

  W0649 detects that right hand side of the shift-expression is
  a constant-expression of negative value.

  Scenario: left shift-expression with negative constant rhs value
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          return i << -1; /* W0649 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0570 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 13     |
      | W0572 | 3    | 14     |
      | W0649 | 3    | 14     |
      | W0794 | 3    | 14     |
      | W0104 | 1    | 13     |
      | W0628 | 1    | 5      |

  Scenario: right shift-expression with negative constant rhs value
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          return i >> -1; /* W0649 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0571 | 3    | 14     |
      | W0572 | 3    | 14     |
      | W0649 | 3    | 14     |
      | W0104 | 1    | 13     |
      | W0628 | 1    | 5      |

  Scenario: left shift-expression with negative constant rhs value derived by
            macro
    Given a target source named "fixture.c" with:
      """
      #define VAL (-1)

      int foo(int i)
      {
          return i << VAL; /* W0649 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0570 | 5    | 14     |
      | C1000 |      |        |
      | C1006 | 3    | 13     |
      | W0572 | 5    | 14     |
      | W0649 | 5    | 14     |
      | W0794 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: right shift-expression with negative constant rhs value derived by
            macro
    Given a target source named "fixture.c" with:
      """
      #define VAL (-1)

      int foo(int i)
      {
          return i >> VAL; /* W0649 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0571 | 5    | 14     |
      | W0572 | 5    | 14     |
      | W0649 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: left shift-expression with positive constant rhs value
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          return i << 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0570 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 13     |
      | W0572 | 3    | 14     |
      | W0794 | 3    | 14     |
      | W0104 | 1    | 13     |
      | W0628 | 1    | 5      |

  Scenario: right shift-expression with positive constant rhs value
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          return i >> 1; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0571 | 3    | 14     |
      | W0572 | 3    | 14     |
      | W0104 | 1    | 13     |
      | W0628 | 1    | 5      |

  Scenario: left shift-expression with zero constant rhs value
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          return i << 0; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0570 | 3    | 14     |
      | C1000 |      |        |
      | C1006 | 1    | 13     |
      | W0572 | 3    | 14     |
      | W0794 | 3    | 14     |
      | W0104 | 1    | 13     |
      | W0628 | 1    | 5      |

  Scenario: right shift-expression with zero constant rhs value
    Given a target source named "fixture.c" with:
      """
      int foo(int i)
      {
          return i >> 0; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0571 | 3    | 14     |
      | W0572 | 3    | 14     |
      | W0104 | 1    | 13     |
      | W0628 | 1    | 5      |

  Scenario: left shift compound-assignment-expression with negative constant
            rhs value
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          i <<= -1; /* W0649 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0570 | 3    | 7      |
      | C1000 |      |        |
      | C1006 | 1    | 14     |
      | W0572 | 3    | 7      |
      | W0649 | 3    | 7      |
      | W0794 | 3    | 7      |
      | W0628 | 1    | 6      |

  Scenario: right shift compound-assignment-expression with negative constant
            rhs value
    Given a target source named "fixture.c" with:
      """
      void foo(int i)
      {
          i >>= -1; /* W0649 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 6      |
      | W0571 | 3    | 7      |
      | W0572 | 3    | 7      |
      | W0649 | 3    | 7      |
      | W0628 | 1    | 6      |

  Scenario: left shift-expression with negative constant rhs value derived by
            enumerator
    Given a target source named "fixture.c" with:
      """
      enum e { VAL = -2 };

      int foo(int i)
      {
          return i << VAL; /* W0649 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0570 | 5    | 14     |
      | C1000 |      |        |
      | C1006 | 3    | 13     |
      | W0572 | 5    | 14     |
      | W0649 | 5    | 14     |
      | W0794 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: right shift-expression with negative constant rhs value derived by
            enumerator
    Given a target source named "fixture.c" with:
      """
      enum e { VAL = -2 };

      int foo(int i)
      {
          return i >> VAL; /* W0649 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0571 | 5    | 14     |
      | W0572 | 5    | 14     |
      | W0649 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: left shift-expression with positive constant rhs value derived by
            enumerator
    Given a target source named "fixture.c" with:
      """
      enum e { VAL = 2 };

      int foo(int i)
      {
          return i << VAL; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0570 | 5    | 14     |
      | C1000 |      |        |
      | C1006 | 3    | 13     |
      | W0572 | 5    | 14     |
      | W0794 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |

  Scenario: right shift-expression with positive constant rhs value derived by
            enumerator
    Given a target source named "fixture.c" with:
      """
      enum e { VAL = 2 };

      int foo(int i)
      {
          return i >> VAL; /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0571 | 5    | 14     |
      | W0572 | 5    | 14     |
      | W0104 | 3    | 13     |
      | W0628 | 3    | 5      |
