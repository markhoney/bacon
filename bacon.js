require("dotenv").config();
require('colors');
const {v3} = require('@leonardocabeza/the-movie-db');
const tmdb = v3(process.env.TheMovieDBKey);
const cache = require('./cache');

async function getShortestPaths(actorNames) { // Kevin Bacon - 4724
	const personToMovies = {};
	const nodesToExamine = [];
	for (const actorName of actorNames) {
		const person = await getPerson(actorName);
		personToMovies[person.id] = undefined;
		nodesToExamine.push(person);
	}
	let commonMovies = getCommonMovies(personToMovies);
	while (commonMovies.size < 1) {
		for (const person in personToMovies) {
			if (personToMovies[person] === undefined) {
				personToMovies[person] = await getMovies(person);
			}
		}
		commonMovies = getCommonMovies(personToMovies);
	}
	return getPaths(actorNames, commonMovies);
}

function getPaths(actorNames, commonMovies) {
	logFunctionCall(arguments.callee, arguments);
	const result = {
		nodes: [],
		links: []
	};
	for (const actorName of actorNames) {
		result.nodes.push({ id: actorName, group: 1 });
		for (const movieJSON of commonMovies) {
			const movie = JSON.parse(movieJSON);
			result.links.push({
				source: actorName,
				target: movie.name,
				value: 1
			});
		}
	}
	for (const movieJSON of commonMovies) {
		const movie = JSON.parse(movieJSON);
		result.nodes.push({ id: movie.name, group: 2 });
	}
	return result;
}

function getCommonMovies(personToMovies) {
	const personIds = Object.keys(personToMovies);
	let arrayOfMovies = personToMovies[personIds[0]];
	if (arrayOfMovies === undefined) return new Set();
	let commonMovies = new Set(arrayOfMovies.map(x => JSON.stringify(x)));
	for (let i = 1; i < personIds.length; ++i) {
		const movies = personToMovies[personIds[i]];
		commonMovies = new Set(
			movies
				.filter(x => commonMovies.has(JSON.stringify(x)))
				.map(x => JSON.stringify(x))
		);
	}
	return commonMovies;
}

async function getMovies(personId) {
	const data = await cache('tmdb/credits/person', personId, tmdb.people.movieCredits, personId); // combinedCredits
	if (data && data.cast && data.cast.length) return data.cast.map((movie) => ({
		type: "movie",
		id: movie.id,
		name: movie.title,
	}));
	return {};
}

async function getPeople(movieId) {
	const data = await cache('tmdb/credits/movie', movieId, tmdb.movie.credits, movieId);
	if (data && data.cast && data.cast.length) return data.cast.map((person) => ({
		type: "person",
		id: person.id,
		name: person.name,
	}));
	return {};
}

// https://oracleofbacon.org/movielinks.php?ajax=1&a=Kevin+Bacon&b=John+Carradine&use_role_types=1&rt0=on

module.exports = getShortestPaths;
