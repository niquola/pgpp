sql = require('../src/honey').sql

console.log(sql)

tests = [
  [
    {
      select: ['Patient',':logical_id'],
      from: ['patient'],
      where: [':=',':logical_id', 1]
    },
    "SELECT 'Patient', logical_id FROM patient WHERE logical_id = 1"
  ]
  [
    {
      select: [':*']
      from: [['patient', 'p'], ['users', 'u']],
      where: [':and',[':=',':logical_id', 'x']
                     [':=', ':version_id', 'y']]
    },
    "SELECT * FROM patient p, users u WHERE (logical_id = 'x' AND version_id = 'y')"
  ]
  [
    {
      select: [':*']
      from: [['patient', 'p']]
      joins: [
        [['encounter', 'e']
         [':=',':e.name',':p.name']]
        [['another', 'a']
         [':=',':a.name',':e.name']]
      ]
      where: [':and'
        [':=',':p.name',4]
        [':=',':a.name',4]
        [':=',':e.name',4]]
    },
    "SELECT * FROM patient p JOIN encounter e ON e.name = p.name JOIN another a ON a.name = e.name WHERE (p.name = 4 AND a.name = 4 AND e.name = 4)"
  ]
]

describe "honey", ()->
  for [q,s] in tests
    it s, ()->
      expect(sql(q)).toEqual(s)
