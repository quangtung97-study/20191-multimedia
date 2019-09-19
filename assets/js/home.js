// @flow
import css from "../css/home.css"
import React, { useState } from "react";
import ReactDOM from "react-dom";
import { createStore } from "redux";
import { Provider } from "react-redux";

const root = document.getElementById("root");

const Hello = () => {
  const [counter, setCounter] = useState(10);
  return (
    <div>
      <h2>TUNG QUANG</h2>
      <h3>{counter}</h3>
      <button onClick={e => setCounter(counter + 1)} >INC</button>
      <button onClick={e => setCounter(counter - 1)} >DEC</button>
    </div>
  );
};

const rootReducer = (counter = 0, action) => {
  switch (action.type) {
    case "INC":
      return counter + 1;
    default:
      return counter;
  }
}

const store = createStore(
  rootReducer,
  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);

if (root)
  ReactDOM.render(
    <Provider store={store}>
      <Hello />
    </Provider>,
    root);

