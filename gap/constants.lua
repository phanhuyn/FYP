-- threshold, for customizing the algo,
-- if (prob (a char following a prefix) < threhold) --> won't put the character into the tree
THRESHOLD = 0.01

-- for fill gap to use sum of prob instead of product
USE_SUM = false

-- for fill gap to multiply the prob with this factor so the prob won't get too small
MAGNIFIY_FACTOR = 20

-- for filtering out character which is very unlikely to happen
CUT_OFF_PROBS = 0.01

-- sum decay factor
SUM_DECAY_FACTOR = 1

-- product decay factor
PRODUCT_DECAY_FACTOR = 0

-- changing method of getting accuracy
COUNT_PER_SYMBOLS = false
