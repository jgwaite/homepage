export interface Project {
	title: string;
	description: string;
	href: string;
}

export const projects: Project[] = [
	{
		title: 'Forge Workout App',
		description: 'A strength training companion focused on programs, progression, and clean tracking.',
		href: 'https://myforge.fit',
	},
	{
		title: 'Engineering Documentation Framework',
		description: 'An agent-powered framework for living requirements, architecture, and decisions',
		href: 'https://github.com/jgwaite/engineering-documentation-framework',
	},
	{
		title: 'Full Stack App Boilerplate',
		description: 'Production-ready patterns for quickly standing up durable, full stack products.',
		href: 'https://github.com/jgwaite/full-stack-app-boilerplate',
	},
];

export default projects;
