MATCH (u:user {id: {p01}})
WITH u
MATCH (u)-[:CONTACT]->(c:contact)-[:CONTACT]->(cr:role)
  WHERE exists(cr.teamid)
WITH c, cr
MATCH (:team {id: cr.teamid})-[:SCHEDULE]->(:calendar)-->(y:year)
  WHERE y.endat >= {p03} AND y.startat <= {p04}
WITH c, cr, y
MATCH (y)-->(w:week)-->(p:project)
  WHERE w.endat >= {p03} AND w.startat <= {p04}
WITH DISTINCT c, cr, p
WITH c, cr, p, [r IN (c)-[:CONTACT]->(:projectrole {projectid: p.id}) | last(nodes(r))] AS prs
  WHERE cr.name IN ['Owners', 'Admins'] OR length(prs) > 0
WITH p, c, cr, extract(r IN prs | r.name) AS prs
WITH p, c,
     {
       accessedby:       c.id,
       accessedteamrole: cr.name,
       accessedrole:     CASE
                           WHEN cr.name IN ['Owners', 'Admins'] THEN cr.name
                           WHEN 'ProjectAdmins' IN prs THEN 'ProjectAdmins'
                           WHEN 'ProjectClients' IN prs THEN 'ProjectClients'
                           WHEN 'ProjectContacts' IN prs THEN 'ProjectContacts'
                           ELSE 'None'
                           END
     } AS r
MATCH (p)-[:TASK]->(:tasks)-->(t:task)-[:SCHEDULE]->(s:schedule)
  WHERE r.accessedrole IN ['Owners', 'Admins', 'ProjectAdmins', 'ProjectClients'] OR (s)<-[:SCHEDULE]-(:week {contactid: c.id})
WITH s, r
MATCH (s)<-[:SCHEDULE]-(:week)<--(:year)<--(:calendar)<--(x:contact)
WITH s, collect(DISTINCT x) AS xs, r
WITH s, {accessedby: r.accessedby, contacts: [x IN xs | {id: x.id, object: 'contact', name: coalesce(x.displayname, x.name)}]} AS r
MATCH (t:task)-[:SCHEDULE]->(s)
WITH s, t, {accessedby: r.accessedby, contacts: r.contacts, task: {id: t.id, object: 'task', name: t.name, description: tostring(t.no)}} AS r
MATCH (t)-->(n)
WITH s, t,
     {
       accessedby: r.accessedby,
       contacts:   r.contacts,
       task:       r.task,
       tasktype:   head([x IN collect(n) WHERE x:tasktype |
                         {
                           id:       x.id,
                           object:   'tasktype',
                           name:     x.name,
                           category: x.category,
                           color:    coalesce(x.color, '#dededc')
                         }])
     } AS r
MATCH ()-[rel]->(t)
WITH s, t,
     {
       accessedby: r.accessedby,
       contacts:   r.contacts,
       task:       r.task,
       tasktype:   r.tasktype,
       alerts:     [x IN collect(rel) WHERE type(x) = 'ALERT' | {id:        x.id,
                                                                 object:    'alert',
                                                                 alerttype: x.alerttype,
                                                                 severity:  coalesce(x.severity, 0),
                                                                 code:      x.code,
                                                                 data:      x.data,
                                                                 createdat: x.createdat}]
     } AS r
MATCH (p:project)
USING INDEX p:project(id)
  WHERE p.id IN [t.projectid]
RETURN
  collect({
    id:              s.id,
    object:          s.object,
    name:            s.name,
    description:     s.description,
    scheduletype:    s.scheduletype,
    startat:         s.startat,
    endat:           s.endat,
    schedules:       s.schedules,
    worklogs:        s.worklogs,
    info:            s.info,
    isautoscheduled: s.isautoscheduled,
    accessedby:      r.accessedby,
    contacts:        r.contacts, task: r.task,
    tasktype:        r.tasktype,
    alerts:          r.alerts,
    project:         {id: p.id, object: 'project', name: p.name, linkdata: {neighborhood: coalesce(p.neighborhood, p.locality)}}
  }) AS r
