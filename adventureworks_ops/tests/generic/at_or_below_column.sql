{% test at_or_below_column(model, column_name, compare_column) %}
-- Asserts column_name <= compare_column on every row; returns the violating rows.
-- compare_column is a custom arg, passed under `arguments:` in the schema YAML.
-- Rows where either side is NULL are skipped (ordering vs NULL is undefined).
SELECT
    {{ column_name }} AS checked_value,
    {{ compare_column }} AS compare_value
FROM {{ model }}
WHERE {{ column_name }} > {{ compare_column }}
{% endtest %}
