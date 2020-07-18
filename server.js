const neo4j = require('neo4j-driver');

const driver = neo4j.driver(uri, neo4j.auth.basic(user, password));
const session = driver.session();
const name = 'Alice';

async function connect() {
	try {
		const result = await session.run(
			'CREATE (a:Person {name: $name}) RETURN a',
			{name}
		);

		const singleRecord = result.records[0];
		const node = singleRecord.get(0);

		console.log(node.properties.name);
	} finally {
		await session.close();
	}

	await driver.close();
}

connect();
