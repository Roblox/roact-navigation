<h1>TopBar API</h1>

NOTE: Since Roact does not currently expose an API for "style" specifically, I use the word "style" to refer to
props in general, with the intention that these props be used solely for "styling."

There are two options to "style" a render prop for the top bar.
You can either bake the props into the render prop itself (preferred), or, if you wish, you may put them into the
appropriate style object, where they will be injected as props as indicated.

The following are the fields that can be provided in the navigationOptions table:

<h3>Entire top bar</h3>

`headerStyle` Style object for the header. Use for things like transparency, color, background image, etc.

<h3>Center part of the top bar (title/subtitle)</h3>

`renderHeaderTitleContainer` Roact Component used as the container for the `headerTitle` and `headerSubtitle`. Receives headerTitle, headerTitleContainerStyle, headerTitleStyle, renderHeaderTitle, headerSubtitle, and renderHeaderSubtitle as props.

`headerTitleContainerStyle` Style object for the container of the title and subtitle components.

`headerTitle` String used by the header.

`renderHeaderTitle` Roact Component used by the header. Receives `headerTitleStyle` as a prop.

`headerTitleStyle` Style object for the title component.

`headerSubtitle` String used by the header. Defaults to blank.

`renderHeaderSubtitle` Roact Component used by the header. Receives `headerSubtitleStyle` as props.

`headerSubtitleStyle` Style object for the subtitle component.

<h3>Left part of the top bar (back button)</h3>

`renderHeaderLeftContainer` Roact Component to display on the left side of the header. Receives `goBack`, `headerLeftContainerStyle`, `headerBackButtonStyle`, and `renderHeaderBackButton` as props.

`headerLeftContainerStyle` Style object for the containing frame of the back button.

`renderHeaderBackButton` Roact Component to display custom image in header's back button. Receives `headerBackButtonStyle` as a prop.

`headerBackButtonStyle` Style object for the header back button.

<h3>Right part of the top bar (icons, etc.)</h3>

`renderHeaderRight` Roact Component to display on the right side of the header.
