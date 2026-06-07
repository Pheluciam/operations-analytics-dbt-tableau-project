{#
    extended_amount — line-level extended-amount business rule, shared by the
    order-line facts so sales and purchase lines compute it identically (no drift).
    Returns a SQL expression spliced into a SELECT at compile time, not a value.

    qty_column       : line quantity column
    price_column     : unit price column
    discount_column  : optional; when supplied, applies (1 - discount) to the result
#}
{% macro extended_amount(qty_column, price_column, discount_column=none) %}
    {%- if discount_column is none -%}
        {{ qty_column }} * {{ price_column }}
    {%- else -%}
        {{ qty_column }} * {{ price_column }} * (1 - {{ discount_column }})
    {%- endif -%}
{% endmacro %}
