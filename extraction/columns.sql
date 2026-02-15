SELECT 
	t.name AS table_name,
	c.name AS column_name,
	ty.name as data_type,
	c.max_length,
	c.is_nullable
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
ORDER BY table_name
