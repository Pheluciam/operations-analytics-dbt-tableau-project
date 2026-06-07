{% test not_negative(model, column_name) %}
-- Fails (returns rows) where a numeric column is below zero.
-- Zero rows returned = pass. NULLs are ignored (NULL < 0 is unknown, not true).
SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} < 0
{% endtest %}
