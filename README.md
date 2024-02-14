# Bowling house API

A Ruby on Rails API that takes score of a bowling game.

## Usage

### _Start a new bowling game_

```plaintext
POST /games
```

```shell
curl --request POST \
  --url "https://example.com/api/v1/games" \
  --header "Authorization: Bearer <your_access_token>, token_id=<your_token_id>"
```

Example response:

```json
{
  "id": 25
}
```

### _Input the number of pins knocked down by the last ball_

```plaintext
POST /games/:id/throw_ball
```

Parameters:

| Attribute | Type    | Required |  Description                   |
| :---------|:--------|:---------|:-------------------------------|
| `id`      | integer | yes      | ID of the in-progress game.    |
| `game`    | object  | yes      | JSON object with the `knocked_pins` key. Value for this key has to be an integer number that is `>=` 0 and `<=` 10. |

```shell
curl --request POST \
  --url "https://example.com/api/v1/games/25/throw_ball" \
  --header "content-type: application/json" \
  --header "Authorization: Bearer <your_access_token>, token_id=<your_token_id>" \
  --data '{
    "game": {
      "knocked_pins": 10
    }
}'
```

Returns the following status codes:

- `204 No Content`: number of pins knocked down by the ball has been saved.
- `401 Unauthorized`: user’s personal access token is invalid.
- `404 Not found`: game with specified id was not found.
- `422 Unprocessable Entity`: expected parameter is missed OR number of pins is invalid OR game is complete.

### _Output the current game score (score for each frame and total score)_

```plaintext
GET /games/:id/score
```

Parameters:

| Attribute | Type    | Required |  Description    |
| :---------|:--------|:---------|:----------------|
| `id`      | integer | yes      | ID of the game. |

```shell
curl --header "Authorization: Bearer <your_access_token>, token_id=<your_token_id>" "https://example.com/api/v1/games/25/score"
```

Example response:

```json
{
  "frame_scores": [
      30,
      60,
      90,
      120,
      150,
      180,
      210,
      240,
      270,
      300
  ],
  "total_score": 300
}
```
