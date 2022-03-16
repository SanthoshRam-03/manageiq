/* eslint-disable react/no-array-index-key */
import * as React from 'react';
import PropTypes from 'prop-types';
import MiqStructuredList from '../miq-structured-list';

const simpleRow = (row, i, colOrder) => (
  <tr key={i} className="no-hover">
    {colOrder.map((col, j) => <td key={j}>{row[col]}</td>)}
  </tr>
);

const clickableRow = (row, i, colOrder, rowLabel, onClick) => (
  <tr key={i}>
    {colOrder.map((col, j) => (
      <td key={j} title={rowLabel}>
        <a href={row.link} onClick={(e) => onClick(row, e)}>
          {`${row[col]}`}
        </a>
      </td>
    ))}
  </tr>
);

const renderRow = (row, i, colOrder, rowLabel, onClick) => (
  row.link ? clickableRow(row, i, colOrder, rowLabel, onClick) : simpleRow(row, i, colOrder)
);

export default function TableListView(props) {
  const { headers, values, title } = props;

  /** Function to generate rows for structured list. */
  const miqListRows = (list) => {
    const data = [];
    list.map((item) => data.push({ ...item, label: item.name }));
    return data;
  };

  return (
    <MiqStructuredList
      headers={headers}
      rows={miqListRows(values)}
      title={title}
      mode="table_list_view"
      onClick={() => props.onClick}
    />
  );
}

TableListView.propTypes = {
  title: PropTypes.string.isRequired,
  headers: PropTypes.arrayOf(PropTypes.string).isRequired,
  values: PropTypes.arrayOf(PropTypes.object).isRequired,
  onClick: PropTypes.func.isRequired,
};