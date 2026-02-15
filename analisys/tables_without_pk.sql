SELECT
	t.name AS table_name,
	s.name AS schema_name
FROM sys.tables t
JOIN sys.schemas s
	ON t.schema_id = s.schema_id
LEFT JOIN sys.key_constraints kc
	ON kc.parent_object_id = t.object_id
	AND kc.type = 'PK'
WHERE kc.object_id IS NULL
ORDER BY s.name, t.name