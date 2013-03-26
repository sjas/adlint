Feature: W1077

  W1077 detects that an array variable declared without number of its elements.

  Scenario: 1-dimensional array variable declaration without size
    Given a target source named "fixture.c" with:
      """
      extern int a[]; /* W1077 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1077 | 1    | 12     |

  Scenario: 1-dimensional array variable declaration with size
    Given a target source named "fixture.c" with:
      """
      extern int a[3]; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |

  Scenario: 2-dimensional array variable declaration without all sizes
    Given a target source named "fixture.c" with:
      """
      extern int a[][]; /* W1077 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1028 | 1    | 12     |
      | W1077 | 1    | 12     |

  Scenario: 2-dimensional array variable declaration without outer size
    Given a target source named "fixture.c" with:
      """
      extern int a[][3]; /* W1077 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1077 | 1    | 12     |

  Scenario: 2-dimensional array variable declaration with all sizes
    Given a target source named "fixture.c" with:
      """
      extern int a[2][3]; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |

  Scenario: 3-dimensional array variable declaration without all sizes
    Given a target source named "fixture.c" with:
      """
      extern int a[][][]; /* W1077 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |
      | W1028 | 1    | 12     |
      | W1077 | 1    | 12     |

  Scenario: 3-dimensional array variable declaration with all sizes
    Given a target source named "fixture.c" with:
      """
      extern int a[1][2][3]; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 12     |

  Scenario: cv-qualified 3-dimensional array variable declaration without all
            sizes
    Given a target source named "fixture.c" with:
      """
      extern const int a[][][]; /* W1077 */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 18     |
      | W1028 | 1    | 18     |
      | W1077 | 1    | 18     |

  Scenario: cv-qualified 3-dimensional array variable declaration with all
            sizes
    Given a target source named "fixture.c" with:
      """
      extern const int a[1][2][3]; /* OK */
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 18     |
