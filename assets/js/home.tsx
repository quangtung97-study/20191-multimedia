import "regenerator-runtime/runtime";
import "../css/home.css"
import * as React from "react";
import { useState } from "react";
import { render } from "react-dom";
import { createStore, applyMiddleware } from "redux";
import { Provider } from "react-redux";
import createSagaMiddleware from "redux-saga";
import { composeWithDevTools } from "redux-devtools-extension";

const root = document.getElementById("root");

const Hello = () => {
  const [counter, setCounter] = useState(10);
  return (
    <div>
      <h2>TUNG QUANG</h2>
      <h3>{counter}</h3>
      <button onClick={_ => setCounter(counter + 1)} >INC</button>
      <button onClick={_ => setCounter(counter - 1)} >DEC</button>
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

const sagaMiddleware = createSagaMiddleware();
const store = createStore(
  rootReducer,
  composeWithDevTools(
    applyMiddleware(sagaMiddleware)
  )
);

function *helloSaga() {
  console.log("Hello Saga");
}

sagaMiddleware.run(helloSaga);

if (root)
  render(
    <Provider store={store}>
      <Hello />
    </Provider>,
    root);
