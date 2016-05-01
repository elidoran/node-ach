
# must:
#  1. exist
#  2. type object
#  3. not an array
module.exports = (object) -> 'object' is typeof object and not Array.isArray object
