SELECT 
	t.name AS table_name,
	kc.name AS pk_name,
	c.name AS column_name
FROM sys.key_constraints kc
JOIN sys.index_columns ic
	ON kc.parent_object_id = ic.object_id
	AND kc.unique_index_id = ic.index_id
JOIN sys.columns c
	ON ic.object_id = c.object_id
	AND ic.column_id = c.column_id
JOIN sys.tables t
	ON t.object_id = kc.parent_object_id
WHERE kc.type = 'PK'
ORDER BY ic.key_ordinal
