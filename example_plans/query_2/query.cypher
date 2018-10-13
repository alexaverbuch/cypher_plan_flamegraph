MATCH (:project {id: {p01}})-[:ACTIVITY*]->(a:activity)
WITH DISTINCT a
  SKIP {p02}
  LIMIT {p03}
MATCH (c:contact {id: a.contactid})
RETURN
  collect({
    id:            a.id,
    object:        a.object,
    values:        a.values,
    createdat:     a.createdat,
    primaryaction: a.primaryaction,
    primaryobject: a.primaryobject,
    primaryno:     a.primaryno,
    primaryname:   a.primaryname,
    primaryid:     a.primaryid,
    createdby:     {id: c.id, object: c.object, name: c.name, description: c.imageurl}
  }) AS r
