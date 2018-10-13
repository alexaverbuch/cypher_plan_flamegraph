MATCH (u:user {id: {p01}}), (p:project {id: {p02}})
WITH u, p
MATCH (u)-[:CONTACT]->(c:contact {teamid: p.teamid})-[:CONTACT]->(cr:role {teamid: p.teamid})
WITH p, c, cr, [r IN (c)-[:CONTACT]->(:projectrole {projectid: p.id}) | last(nodes(r))] AS prs
WITH p, c, cr, extract(r IN prs | r.name) AS prs
WITH p,
     c,
     {
       accessedby:       c.id,
       accessedteamrole: cr.name,
       accessedrole:     CASE
                           WHEN cr.name IN ['Owners', 'Admins']THEN cr.name
                           WHEN 'ProjectAdmins' IN prs THEN 'ProjectAdmins'
                           WHEN 'ProjectClients' IN prs THEN 'ProjectClients'
                           WHEN 'ProjectContacts' IN prs THEN 'ProjectContacts'
                           ELSE 'None'
                           END
     } AS r
RETURN
  collect({
    id:             p.id,
    object:         p.object,
    status:         p.status,
    teamid:         p.teamid,
    no:             p.no,
    name:           p.name,
    description:    p.description,
    street:         p.street,
    locality:       p.locality,
    region:         p.region,
    postcode:       p.postcode,
    country:        p.country,
    neighborhood:   p.neighborhood,
    latlnglocation: p.latlnglocation,
    imageurl:       p.imageurl,
    workhours:      p.workhours,
    startat:        p.startat,
    endat:          p.endat,
    budget:         p.budget,
    isfixedcost:    p.isfixedcost,
    fixedcost:      p.fixedcost,
    deposit:        p.deposit,
    timezone:       p.timezone,
    materialmarkup: p.materialmarkup,
    isbid:          p.isbid,
    salestax:       p.salestax,
    accessedby:     r.accessedby,
    accessedrole:   r.accessedrole
  }) AS r
